import 'package:firebase_database/firebase_database.dart';
import '../Interface/DataOperationCallback.dart';
import '../Interface/IPostLike.dart';
import '../Interface/OperationCallback.dart';
import '../ModelData/LikeResult.dart';
import '../ModelData/PostLike.dart';
import '../ModelData/Users.dart';
import 'UserPostService.dart';
import 'UserService.dart';

class PostLikeService implements IPostLike {
  final DatabaseReference reference;
  static const String _collectionName = "postlike";
  final UserPostService userPostService;
  final UserService userService;

  PostLikeService()
      : reference = FirebaseDatabase.instance.ref(),
        userPostService = UserPostService(),
        userService = UserService();

  @override
  void likeAndUnlikePost(String postId, String userId, DataOperationCallback<LikeResult> callback) {
    getPostLikeByUserAndPostId(postId, userId, DataOperationCallback<PostLike?>(
      onSuccess: (existingPostLike) {
        if (existingPostLike != null) {
          reference.child(_collectionName).child(existingPostLike.postlikeId!).remove().then((_) {
            userPostService.updateLikeCount(postId, -1, DataOperationCallback<int>(
              onSuccess: (newCount) {
                callback.onSuccess(LikeResult(newCount, false));
              },
              onFailure: (error) {
                callback.onFailure(error);
              },
            ));
          }).catchError((error) {
            callback.onFailure(error.toString());
          });
        } else {
          String newItemKey = reference.child(_collectionName).push().key!;
          PostLike model = PostLike(postId: postId, userId: userId)..postlikeId = newItemKey;

          reference.child(_collectionName).child(newItemKey).set(model.toJson()).then((_) {
            userPostService.updateLikeCount(postId, 1, DataOperationCallback<int>(
              onSuccess: (newCount) {
                callback.onSuccess(LikeResult(newCount, true));
              },
              onFailure: (error) {
                callback.onFailure(error);
              },
            ));
          }).catchError((error) {
            callback.onFailure(error.toString());
          });
        }
      },
      onFailure: (error) {
        callback.onFailure(error);
      },
    ));
  }

  @override
  void getPostLikeByUserAndPostId(String postId, String userId, DataOperationCallback<PostLike?> callback) {
    reference.child(_collectionName).once().then((snapshot) {
      for (var userSnapshot in snapshot.snapshot.children) {
        if (userSnapshot.value is Map) {
          PostLike postLike = PostLike.fromJson(Map<String, dynamic>.from(userSnapshot.value as Map));
          if (postLike.userId == userId && postLike.postId == postId) {
            callback.onSuccess(postLike);
            return;
          }
        }
      }
      callback.onSuccess(null);
    }).catchError((error) {
      callback.onFailure(error.toString());
    });
  }

  @override
  Future<void> getLikesForPost(String postId, DataOperationCallback<List<PostLike>> callback) async {
    List<PostLike> likesWithUsers = [];

    try {
      final snapshot = await reference.child(_collectionName).orderByChild("postId").equalTo(postId).once();
      if (snapshot.snapshot.children.isEmpty) {
        callback.onSuccess(likesWithUsers);
        return;
      }

      for (var likeSnapshot in snapshot.snapshot.children) {
        if (likeSnapshot.value is Map) {
          PostLike postLike = PostLike.fromJson(Map<String, dynamic>.from(likeSnapshot.value as Map));
          Users? userDetails = await getUserDetails(postLike.userId);
          if (userDetails != null) {
            postLike.username = userDetails.username;
            postLike.profilepicture = userDetails.profilepicture;
          }
          likesWithUsers.add(postLike);
        }
      }
      callback.onSuccess(likesWithUsers);
    } catch (error) {
      callback.onFailure(error.toString());
    }
  }

  Future<Users?> getUserDetails(String userId) async {
    return await userService.getUserByID(userId);
  }

  @override
  void removeLike(String postlikeId, String postId, OperationCallback callback) {
    reference.child(_collectionName).child(postlikeId).remove().then((_) {
      userPostService.updateLikeCount(postId, -1, DataOperationCallback<int>(
        onSuccess: (newLikeCount) {
          callback.onSuccess();
        },
        onFailure: (error) {
          callback.onFailure(error);
        },
      ));
    }).catchError((error) {
      callback.onFailure(error.toString());
    });
  }
}
