import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:io';
import 'dart:math';

import '../Interface/DataOperationCallback.dart';
import '../Interface/IPostImagesInterface.dart';
import '../Interface/OperationCallback.dart';
import '../ModelData/PostImages.dart';
import 'dart:typed_data';

class PostImagesService implements IPostImagesInterface {
  final DatabaseReference reference;
  final FirebaseStorage storage;
  static const String _collectionName = "postimages";

  PostImagesService()
      : reference = FirebaseDatabase.instance.ref(),
        storage = FirebaseStorage.instance;

  @override
  Future<void> addPostPhotos(PostImages model, OperationCallback callback) async {
    try {
      String newItemKey = reference.child(_collectionName).push().key!;
      model.imageId = newItemKey;

      await reference.child(_collectionName).child(newItemKey).set(model.toJson());
      callback.onSuccess();
    } catch (e) {
      callback.onFailure(e.toString());
    }
  }
  @override
  Future<void> uploadImages(String postId, List<Uri> imageUris, OperationCallback callback) async {
    List<Future> uploadTasks = [];

    for (int i = 0; i < imageUris.length; i++) {
      int order = i + 1;
      Uri imageUri = imageUris[i];

      String filePath = 'postimages/$postId/${_generateUUID()}';
      Reference fileReference = storage.ref(filePath);


      Future<void> uploadTask = () async {
        try {

          File file = File(imageUri.path);
          if (await file.exists()) {
            List<int> fileBytes = await file.readAsBytes();
            await fileReference.putData(Uint8List.fromList(fileBytes));
            String downloadUrl = await fileReference.getDownloadURL();
            PostImages photos = PostImages(postId: postId, imagePath: downloadUrl, order: order);

            await addPostPhotos(photos, OperationCallback(
              onSuccess: () {
                callback.onSuccess();
              },
              onFailure: (errMessage) {
                callback.onFailure(errMessage);
              },
            ));
          } else {
            callback.onFailure("File does not exist: ${imageUri.path}");
          }
        } catch (e) {
          callback.onFailure(e.toString());
        }
      }();
      uploadTasks.add(uploadTask);
    }

    await Future.wait(uploadTasks);
    callback.onSuccess();
  }
  @override
  Future<void> getAllPhotosByPostId(String postId, DataOperationCallback<List<String>> callback) async {
    reference.child(_collectionName).orderByChild('postId').equalTo(postId).onValue.listen((event) {
      final List<Map<String, dynamic>> imagesWithOrder = [];

      final data = event.snapshot.value as Map<dynamic, dynamic>?; // Casting to Map
      if (data != null) {
        data.forEach((key, value) {
          // Assuming the value is a Map representing PostImages
          imagesWithOrder.add({
            'imagePath': value['imagePath'] as String,
            'order': value['order'] as int,
          });
        });
      }

      // Sort by the 'order' field
      imagesWithOrder.sort((a, b) => a['order'].compareTo(b['order']));

      // Extract the image paths in order
      final List<String> imagePaths = imagesWithOrder.map((image) => image['imagePath'] as String).toList();
      print("imge path ${imagePaths.length}");
      callback.onSuccess(imagePaths);
    }, onError: (error) {
      callback.onFailure(error.toString());
    });
  }
  Future<void> deleteAllPostImages(String postId, OperationCallback callback) async {
    Query photoRef = reference.child(_collectionName).orderByChild("postId").equalTo(postId);

    photoRef.once().then((snapshot) async {
      if (snapshot.snapshot.exists) {
        List<Future<void>> deleteTasks = [];

        for (var childSnapshot in snapshot.snapshot.children) {
          String? photoPath = childSnapshot.child("imagePath").value as String?;
          if (photoPath != null) {
            // Delete image from Firebase Storage
            await deleteImageFromStorage(photoPath);

            // Remove the entry from the database
            deleteTasks.add(childSnapshot.ref.remove());
          }
        }

        await Future.wait(deleteTasks);
        callback.onSuccess();
      } else {
        callback.onFailure("No photos found for this postId.");
      }
    }).catchError((error) {
      callback.onFailure("Database operation failed: $error");
    });
  }
  Future<void> deleteImage(String postId, String photoPath, OperationCallback callback) async {
    DatabaseReference photoRef = reference.child(_collectionName);

    try {
      final snapshot = await photoRef.once();
      if (snapshot.snapshot.exists) {
        bool photoFound = false;

        for (var childSnapshot in snapshot.snapshot.children) {
          String storedPostId = childSnapshot.child("postId").value as String;
          String storedPhotoPath = childSnapshot.child("imagePath").value as String;

          if (storedPostId == postId && storedPhotoPath == photoPath) {
            photoFound = true;

            await childSnapshot.ref.remove().then((_) async {
              await deleteImageFromStorage(storedPhotoPath);
              await updatePhotoOrder(postId, callback);
              callback.onSuccess();
            }).catchError((error) {
              callback.onFailure("Failed to delete database entry. Error: $error");
            });
          }
        }

        if (!photoFound) {
          callback.onFailure("Photo path not found in the database.");
        }
      } else {
        callback.onFailure("Task failed. No photos found.");
      }
    } catch (error) {
      callback.onFailure("Task failed. Error: $error");
    }
  }

  Future<void> deleteImageFromStorage(String photoPath) async {
    try {
      Reference storageRef = storage.refFromURL(photoPath);
      await storageRef.delete();
      print("Image deleted from Firebase Storage.");
    } catch (e) {
      print("Failed to delete image from Firebase Storage: $e");
    }
  }

  Future<void> updatePhotoOrder(String postId, OperationCallback callback) async {
    DatabaseReference photosRef = reference.child(_collectionName);

    try {
      final dataSnapshot = await photosRef.orderByChild("postId").equalTo(postId).once();
      if (!dataSnapshot.snapshot.exists) {
        callback.onFailure("No photos found for this postId.");
        return;
      }

      int order = 1;
      bool failureOccurred = false;

      for (var snapshot in dataSnapshot.snapshot.children) {
        await snapshot.ref.child("order").set(order).catchError((error) {
          if (!failureOccurred) {
            failureOccurred = true;
            callback.onFailure("Error updating photo order: $error");
          }
        });
        order++;
      }

      if (!failureOccurred) {
        callback.onSuccess();
      }
    } catch (error) {
      callback.onFailure("Database operation cancelled: $error");
    }
  }


  String _generateUUID() {
    return '${_randomString(8)}-${_randomString(4)}-${_randomString(4)}-${_randomString(4)}-${_randomString(12)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
