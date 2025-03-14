import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart';
import 'package:socialtrailsapp/ModelData/PostComment.dart';
import 'package:socialtrailsapp/Utility/FollowService.dart';
import 'package:socialtrailsapp/Utility/PostCommentService.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';

import '../Interface/DataOperationCallback.dart';
import '../Interface/IUserPostInterface.dart';
import '../Interface/OperationCallback.dart';
import '../ModelData/UserPost.dart';
import '../ModelData/Users.dart';
import 'PostImagesService.dart';
import 'Utils.dart';


class UserPostService implements IUserPostInterface {
  final DatabaseReference reference;
  static const String _collectionName = "post";
  final PostImagesService postImagesService;
  final UserService userService;
  final PostCommentService postCommentService;
  final FollowService followService;
  UserPostService()
      : reference = FirebaseDatabase.instance.ref(),
        postImagesService = PostImagesService(),
        userService = UserService(),
        followService = FollowService(),
        postCommentService = PostCommentService();


  @override
  Future<void> createPost(UserPost userPost, DataOperationCallback<String> callback) async {
    try {
      String newItemKey = reference.child(_collectionName).push().key!;
      userPost.postId = newItemKey;

      await reference.child(_collectionName).child(newItemKey).set(userPost.toJson());

      postImagesService.uploadImages(newItemKey, userPost.imageUris, OperationCallback(
        onSuccess: () {
          print("Images uploaded successfully.");

          callback.onSuccess(newItemKey);
        },
        onFailure: (error) {
          print("Image upload failed: $error");
          callback.onFailure(error);
        },
      ));

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
            if (userId == post.userId) {
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
            if (userId == post.userId ) {
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
      completer.complete(0);
    });

    return completer.future; // Return the completer future
  }

  Future<void> retrievePostsForFollowedUsers(String currentUserId, DataOperationCallback<List<UserPost>> callback) async {
    try {
      // Fetch followed user IDs
      List<String> followedUserIds = await followService.getFollowAndFollowerIdsByUserId(currentUserId);
      print("post followers count: ${followedUserIds.length}");

      if (followedUserIds.isEmpty) {
        print("No followed users");
        callback.onSuccess([]); // Return an empty list
        return;
      }

      List<UserPost> postList = [];
      List<Future<void>> postFutures = [];

      for (String userId in followedUserIds) {
        postFutures.add(getAllUserPostDetail(userId, DataOperationCallback<List<UserPost>>(
          onSuccess: (posts) {
            print("Post count for user $userId: ${posts.length}");
            postList.addAll(posts);
          },
          onFailure: (error) {
            print("Error fetching posts for user $userId: $error");
          },
        )));
      }

      // Wait for all post retrievals to complete
      await Future.wait(postFutures);
      print("Total post list count: ${postList.length}");
      callback.onSuccess(postList);
    } catch (e) {
      callback.onFailure("Error retrieving posts: ${e.toString()}");
    }
  }

  Future<void> updateLikeCount(String postId, int change, DataOperationCallback<int> callback) async {
    try {
      DatabaseReference postRef = reference.child(_collectionName).child(postId).child('likecount');

      final DatabaseEvent event = await postRef.once();
      final DataSnapshot snapshot = event.snapshot;
      int currentCount = (snapshot.value as int?) ?? 0;


      currentCount += change;
      await postRef.set(currentCount);

      callback.onSuccess(currentCount);
    } catch (e) {
      callback.onFailure(e.toString());
    }
  }

  Future<void> getUserPostDetailById(String postId, DataOperationCallback<UserPost> callback) async {
    try {
      final snapshot = await reference.child(_collectionName).child(postId).once();
      if (snapshot.snapshot.exists) {
        Map<String, dynamic> postData = Map<String, dynamic>.from(snapshot.snapshot.value as Map<dynamic, dynamic>);
        UserPost post = UserPost.fromJson(postData);
        post.postId = postId;

        // Fetch the image URIs for the post
        List<String> imageUris = await getAllPhotosAsync(postId);
        post.uploadedImageUris = imageUris;

        Users? userDetails = await getUserDetails(post.userId);
        post.username = userDetails?.username;
        post.userprofilepicture = userDetails?.profilepicture;

        int commentCount = await countCommentsForPost(post.postId ?? "");
        post.commentcount = commentCount;
        callback.onSuccess(post);
      } else {
        callback.onFailure("Post not found or user does not have access to it");
      }
    } catch (e) {
      callback.onFailure(e.toString());
    }
  }
  @override
  Future<void> deleteAllLikesForPost(String postId, Function() onSuccess, Function(String) onFailure) async {
    try {
      final snapshot = await reference.child("postlike").orderByChild("postId").equalTo(postId).once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        List<Future<void>> deleteTasks = [];

        data.forEach((key, value) {
          deleteTasks.add(reference.child("postlike").child(key).remove());
        });

        await Future.wait(deleteTasks);
        onSuccess();
      } else {
        onSuccess();
      }
    } catch (e) {
      onFailure("Failed to delete comments: ${e.toString()}");
    }
  }
  @override
  Future<void> deleteUserPost(String postId, OperationCallback callback) async {
    // First, delete all associated comments
    await postCommentService.deleteAllCommentsForPost(
      postId,
          () { // Change here
        // This callback doesn't take parameters, matching Function()
        // Then delete all associated likes
        deleteAllLikesForPost(
          postId,
              () { // Change here
            // Now delete all associated images
            postImagesService.deleteAllPostImages(
              postId,
              OperationCallback(
                onSuccess: () async {
                  // Finally, delete the post itself
                  try {
                    await reference.child(_collectionName).child(postId).remove();
                    callback.onSuccess(); // Notify success
                  } catch (e) {
                    callback.onFailure("Failed to delete post: ${e.toString()}");
                  }
                },
                onFailure: (error) {
                  callback.onFailure("Failed to delete images: $error");
                },
              ),
            );
          },
              (error) {
            callback.onFailure("Failed to delete likes: $error");
          },
        );
      },
          (error) {
        callback.onFailure("Failed to delete comments: $error");
      },
    );
  }

  @override
  Future<void> getPostByPostId(String postId, DataOperationCallback<UserPost> callback) async {
    try {
      final snapshot = await reference.child(_collectionName).child(postId).once();

      if (snapshot.snapshot.exists) {
        UserPost post = UserPost.fromJson(Map<String, dynamic>.from(snapshot.snapshot.value as Map));
        post.postId = postId;

        List<String> imageUris = await getAllPhotosAsync(post.postId ?? "");
        post.uploadedImageUris = imageUris;
        callback.onSuccess(post);
      } else {
        callback.onFailure("Post not found");
      }
    } catch (e) {
      callback.onFailure(e.toString());
    }
  }

  @override
  Future<void> updateUserPost(UserPost post, OperationCallback callback) async {
    post.updatedon = Utils.getCurrentDatetime();

    try {
      // Ensure postId is not null
      if (post.postId != null) {
        await reference.child(_collectionName).child(post.postId!).update(post.toMapUpdate());
        callback.onSuccess();
      } else {
        callback.onFailure("Post ID cannot be null.");
      }
    } catch (e) {
      callback.onFailure(e.toString());
    }
  }

  @override
  Future<void> getPostCount(DataOperationCallback<int> callback) async {
    try {
      final DatabaseEvent event = await reference.child(_collectionName).once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.children.isNotEmpty) {
        int count = snapshot.children.length; // Get the number of children (posts)
        callback.onSuccess(count);
      } else {
        callback.onSuccess(0); // No posts found
      }
    } catch (error) {
      callback.onFailure(error.toString()); // Handle errors
    }
  }

}