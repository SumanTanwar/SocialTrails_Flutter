import 'package:flutter/material.dart';
import 'ModelData/PostComment.dart';
import 'ModelData/UserRole.dart';
import 'Utility/PostCommentService.dart';
import 'Utility/SessionManager.dart';
import 'Utility/Utils.dart';

class CommentDialog extends StatefulWidget {
  final String postId;
  final String userId;
  final Function(int) onCommentCountUpdated;

  const CommentDialog({
    Key? key,
    required this.postId,
    required this.userId,
    required this.onCommentCountUpdated,
  }) : super(key: key);

  @override
  _CommentDialogState createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final PostCommentService postCommentService = PostCommentService();
  final TextEditingController commentController = TextEditingController();
  List<PostComment> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      isLoading = true;
    });

    postCommentService.retrieveComments(
      widget.postId,
          (fetchedComments) {
        setState(() {
          comments = fetchedComments;
          isLoading = false;
        });
      },
          (error) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching comments: $error");
      },
    );
  }

  void _addComment() {
    String commentText = commentController.text.trim();
    if (commentText.isNotEmpty) {
      PostComment newComment = PostComment(
        postId: widget.postId,
        userId: widget.userId,
        commenttext: commentText,
      );
      postCommentService.addPostComment(newComment, () {
        setState(() {
          _fetchComments();
          commentController.clear();
          widget.onCommentCountUpdated(comments.length + 1);
        });
      }, (error) {
        Utils.showError(context,"Error adding comment: $error");
      });
    }
    else
      {
        Utils.showError(context,"Please enter a comment before sending.");
      }

  }

  void _confirmDelete(String commentId, int position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              _deleteComment(commentId, position);
              Navigator.of(context).pop();
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _deleteComment(String commentId, int position) {
    postCommentService.removePostComment(
      commentId,
          () {
        setState(() {
          comments.removeAt(position);
          // Update the comment count here
          widget.onCommentCountUpdated(comments.length);
        });
      },
          (error) {
            Utils.showError(context,"Failed to delete comment: $error");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Comments'),
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (comments.isEmpty)
              Center(child: Text('No comments yet.'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(comment.userprofilepicture ?? 'assets/user.png'),
                      ),
                      title: Text(comment.username ?? 'Unknown User'),
                      subtitle: Text(comment.commenttext),
                      trailing: _shouldShowDeleteButton(comment)
                          ? IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(comment.postcommentId!, index),
                      )
                          : null,
                    );
                  },
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'Add a comment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.purple, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDeleteButton(PostComment comment) {
    String? currentUserRole = SessionManager().getRoleType();
    String? currentUserId = SessionManager().getUserID();

    if (currentUserRole == UserRole.user.getRole() &&
        (comment.userId == currentUserId || currentUserId == widget.userId)) {
      return true;
    } else if (currentUserRole == UserRole.admin.getRole() || currentUserRole == UserRole.moderator.getRole()) {
      return true;
    }
    return false;
  }
}
