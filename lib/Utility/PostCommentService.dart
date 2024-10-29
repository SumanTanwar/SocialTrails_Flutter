import 'package:firebase_database/firebase_database.dart';

import '../Interface/IPostComment.dart';
import '../ModelData/PostComment.dart';
import '../ModelData/Users.dart';
import 'UserService.dart';



class PostCommentService implements IPostComment{
  final DatabaseReference reference;
  static const String _collectionName = "postcomment";
  final UserService userService;

  PostCommentService()
      : reference = FirebaseDatabase.instance.ref(),
        userService = UserService();


  @override
  Future<void> retrieveComments(String postId, Function(List<PostComment>) onSuccess,
      Function(String) onFailure) async {
    List<PostComment> comments = [];

    try {
      final snapshot = await reference.child(_collectionName).orderByChild("postId").equalTo(postId).once();
      if (snapshot.snapshot.children.isEmpty) {
        onSuccess(comments);
        return;
      }

      for (var commentSnapshot in snapshot.snapshot.children) {
        if (commentSnapshot.value is Map) {
          PostComment data = PostComment.fromJson(Map<String, dynamic>.from(commentSnapshot.value as Map));
          Users? userDetails = await getUserDetails(data.userId);
          if (userDetails != null) {
            data.username = userDetails.username;
            data.userprofilepicture = userDetails.profilepicture;
          }
          comments.add(data);
        }
      }
      onSuccess(comments);
    } catch (e) {
      onFailure(e.toString());
    }
  }


  Future<Users?> getUserDetails(String userId) async {
    return await userService.getUserByID(userId);
  }
  @override
  Future<void> addPostComment(PostComment data, Function() onSuccess, Function(String) onFailure) async {
    try {
      String newItemKey = reference.child(_collectionName).push().key!;
      data.postcommentId = newItemKey;

      await reference.child(_collectionName).child(newItemKey).set(data.toJson());
      onSuccess();
    } catch (e) {
      onFailure(e.toString());
    }
  }

  @override
  Future<void> removePostComment(String commentId, Function() onSuccess, Function(String) onFailure) async {
    try {
      await reference.child(_collectionName).child(commentId).remove();
      onSuccess();
    } catch (e) {
      onFailure(e.toString());
    }
  }

  @override
  Future<void> deleteAllCommentsForPost(String postId, Function() onSuccess, Function(String) onFailure) async {
    try {
      final snapshot = await reference.child(_collectionName).orderByChild("postId").equalTo(postId).once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        List<Future<void>> deleteTasks = [];

        data.forEach((key, value) {
          deleteTasks.add(reference.child(_collectionName).child(key).remove());
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


}
