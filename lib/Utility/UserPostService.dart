import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart';
import '../Interface/DataOperationCallback.dart';
import '../Interface/IUserPostInterface.dart';
import '../Interface/OperationCallback.dart';
import '../ModelData/UserPost.dart';
import 'PostImagesService.dart';

class UserPostService implements IUserPostInterface {
  final DatabaseReference reference;
  static const String _collectionName = "post";
  final PostImagesService postImagesService;

  UserPostService()
      : reference = FirebaseDatabase.instance.ref(),
        postImagesService = PostImagesService();

  @override
  Future<void> createPost(UserPost userPost, OperationCallback callback) async {
    try {
      String newItemKey = reference.child(_collectionName).push().key!;
      userPost.postId = newItemKey;
      await reference.child(_collectionName).child(newItemKey).set(userPost.toJson());
      await  postImagesService.uploadImages(newItemKey, userPost.imageUris,OperationCallback(onSuccess: (){
        print("Images uploaded successfully.");
        callback.onSuccess();
      }, onFailure:(e){
        print("Images failed successfully. $e");
        callback.onFailure(e.toString());
      }));
      callback.onSuccess();
    } catch (e) {
      callback.onFailure(e.toString());
    }
  }
  @override
  Future<void> getAllUserPost(String userId, DataOperationCallback<List<UserPost>> callback) async {
    try {
      final snapshot = await reference.child(_collectionName).once();
      List<UserPost> postList = [];
      List<UserPost> tempList = [];

      if (snapshot.snapshot.exists) {
        for (var childSnapshot in snapshot.snapshot.children) {
          final value = childSnapshot.value;
         // print("post list ${childSnapshot.value}");
          if (value is Map) {
            print("enter in map");
            Map<String, dynamic> postData = Map<String, dynamic>.from(value);
            UserPost post = UserPost.fromJson(postData);
            print("post  ${post.userId}");
            if (userId == post.userId && !post.postdeleted) {
              post.postId = childSnapshot.key;
              tempList.add(post);
              print("added  ${post.postId}");
            }
          }
        }
      }
      print("templist  ${tempList.length}");
      if (tempList.isEmpty) {
        callback.onSuccess(postList);
        return;
      }

      // Collect futures for retrieving images
      List<Future<void>> imageFutures = [];

      for (UserPost post in tempList) {
        imageFutures.add(Future(() async {
          List<String> imageUris = await getAllPhotosAsync(post.postId ?? "");
          post.uploadedImageUris = imageUris;
          print("post image count : ${post.uploadedImageUris.length}");// Set the retrieved images
          postList.add(post);
        }));
      }

     // Wait for all image retrievals to complete
     await Future.wait(imageFutures);

     // Sort posts once after all images are retrieved
      postList.sort((post1, post2) {
        final createdOn1 = post1.createdon;
        final createdOn2 = post2.createdon;

        if (createdOn1 == null && createdOn2 == null) return 0;
        if (createdOn1 == null) return 1;
        if (createdOn2 == null) return -1;

        return createdOn2.compareTo(createdOn1);
      });
       print("post list count : ${postList.length}");
      callback.onSuccess(postList);
    } catch (e) {
      callback.onFailure(e.toString());
    }
  }

// Helper method to retrieve photos asynchronously
  Future<List<String>> getAllPhotosAsync(String postId) async {
    Completer<List<String>> completer = Completer();

    getAllPhotos(postId, (imageUris) {
      completer.complete(imageUris);
    }, (error) {
      completer.completeError(error);
    });

    return completer.future;
  }
  void getAllPhotos(String postId, Function(List<String>) onSuccess, Function(String) onFailure) {
    postImagesService.getAllPhotosByPostId(postId, DataOperationCallback<List<String>>(
        onSuccess: (imageUris) {
          onSuccess(imageUris);
        },
        onFailure: (error) {
          onFailure(error);
        }
    ));
  }
}
