import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:socialtrailsapp/ModelData/PostComment.dart';
import 'package:socialtrailsapp/Utility/PostCommentService.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';

import '../Interface/DataOperationCallback.dart';
import '../Interface/IUserPostInterface.dart';
import '../Interface/OperationCallback.dart';
import '../ModelData/UserPost.dart';
import '../ModelData/Users.dart';
import 'PostImagesService.dart';

class UserPostService implements IUserPostInterface {
  final DatabaseReference reference;
  static const String _collectionName = "post";
  final PostImagesService postImagesService;
  final UserService userService;
  final PostCommentService postCommentService;
  UserPostService()
      : reference = FirebaseDatabase.instance.ref(),
        postImagesService = PostImagesService(),
        userService = UserService(),
        postCommentService = PostCommentService();

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
  Future<void> getAllUserPostDetail(String userId, DataOperationCallback<List<UserPost>> callback) async {
    try {
      final snapshot = await reference.child(_collectionName).once();
      List<UserPost> postList = [];
      List<UserPost> tempList = [];

      if (snapshot.snapshot.exists) {
        for (var childSnapshot in snapshot.snapshot.children) {
          final value = childSnapshot.value;
          if (value is Map) {
            Map<String, dynamic> postData = Map<String, dynamic>.from(value);
            UserPost post = UserPost.fromJson(postData);
            if (userId == post.userId && !post.postdeleted) {
              post.postId = childSnapshot.key;
              tempList.add(post);
            }
          }
        }
      }

      if (tempList.isEmpty) {
        callback.onSuccess(postList); // Return empty list if no posts found
        return;
      }

      List<Future<void>> postFutures = [];

      for (UserPost post in tempList) {
        postFutures.add(Future(() async {
          List<String> imageUris = await getAllPhotosAsync(post.postId ?? "");
          post.uploadedImageUris = imageUris;

          Users? userDetails = await getUserDetails(post.userId);
          post.username = userDetails?.username;
          post.userprofilepicture = userDetails?.profilepicture;

          int commentCount = await countCommentsForPost(post.postId ?? "");
          post.commentcount = commentCount;

          postList.add(post);
        }));
      }

      await Future.wait(postFutures);

      postList.sort((post1, post2) => post2.createdon!.compareTo(post1.createdon!));
      callback.onSuccess(postList); // Call onSuccess with the populated list
    } catch (e) {
      callback.onFailure(e.toString()); // Use callback for failure
    }
  }




  Future<Users?> getUserDetails(String userId) async {
    Users? user = await userService.getUserByID(userId);
    return user;
  }

  Future<int> countCommentsForPost(String postId) async {
    Completer<int> completer = Completer();

    postCommentService.retrieveComments(postId, (comments) {
      completer.complete(comments.length);
    }, (error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}
