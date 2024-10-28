import 'package:firebase_database/firebase_database.dart';

import '../Interface/IPostComment.dart';
import '../ModelData/PostComment.dart';
import 'UserService.dart';



class PostCommentService implements IPostComment{
  final DatabaseReference reference;
  static const String _collectionName = "postcomment";
  final UserService userService;

  PostCommentService()
      : reference = FirebaseDatabase.instance.ref(),
        userService = UserService();

  @override
  Future<void> retrieveComments(String postId, Function(List<PostComment>) onSuccess, Function(String) onFailure) async {
    try {
      final snapshot = await reference.child(_collectionName).orderByChild("postId").equalTo(postId).once();

      if (snapshot.snapshot.value != null) {
        List<PostComment> comments = [];
        Map<dynamic, dynamic> data = snapshot.snapshot.value as Map<dynamic, dynamic>;

        int count = 0; // Track completed user fetches

        for (var entry in data.entries) {
          PostComment comment = PostComment.fromJson(entry.value);
          comment.postcommentId = entry.key;

          // Fetch user details
          userService.getUserByID(comment.userId).then((user) {
            if (user != null) {
              comment.username = user.username;
              comment.userprofilepicture = user.profilepicture;
            }
            count++;

            if (count == data.length) {
              onSuccess(comments);
            }
          }).catchError((error) {
            count++;
            if (count == data.length) {
              onSuccess(comments);
            }
          });

          comments.add(comment);
        }

        if (comments.isEmpty) {
          onSuccess(comments);
        }
      } else {
        onSuccess([]);
      }
    } catch (e) {
      onFailure(e.toString());
    }
  }
}
