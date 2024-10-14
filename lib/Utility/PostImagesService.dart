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


  String _generateUUID() {
    return '${_randomString(8)}-${_randomString(4)}-${_randomString(4)}-${_randomString(4)}-${_randomString(12)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
