import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socialtrailsapp/AdminPanel/adminusermanage.dart';
import 'package:socialtrailsapp/ModelData/UserPost.dart';
import 'package:socialtrailsapp/ModelData/UserRole.dart';
import 'package:socialtrailsapp/Utility/UserPostService.dart';
import 'package:socialtrailsapp/Utility/PostCommentService.dart';
import 'package:socialtrailsapp/Utility/Utils.dart';
import '../Interface/DataOperationCallback.dart';
import '../Interface/OperationCallback.dart';
import '../ModelData/PostComment.dart';
import '../ModelData/PostLike.dart';
import '../Utility/PostLikeService.dart';
import '../Utility/SessionManager.dart';

class AdminPostDetailScreen extends StatefulWidget {
  final String postId;

  AdminPostDetailScreen({required this.postId});

  @override
  _AdminPostDetailScreenState createState() => _AdminPostDetailScreenState();
}

class _AdminPostDetailScreenState extends State<AdminPostDetailScreen> {
  late Future<UserPost> postFuture;
  late Future<List<PostComment>> commentsFuture;
  late Future<List<PostLike>> likesFuture;
  final UserPostService userPostService = UserPostService();
  final PostCommentService postCommentService = PostCommentService();
  final PostLikeService postLikeService = PostLikeService();

  int commentCount = 0; // Initialize comment count
  int likeCount = 0;    // Initialize like count
  String? userId;
  @override
  void initState() {
    super.initState();
    postFuture = getUserPostDetails(widget.postId);
    commentsFuture = fetchComments(widget.postId);
    likesFuture = fetchLikes(widget.postId);
  }

  Future<UserPost> getUserPostDetails(String postId) async {
    Completer<UserPost> completer = Completer();

    userPostService.getUserPostDetailById(postId, DataOperationCallback<UserPost>(
      onSuccess: (userPost) {
        likeCount = userPost.likecount;
        commentCount = userPost.commentcount;
        userId = userPost.userId;
        completer.complete(userPost);
      },
      onFailure: (error) {
        completer.completeError(error);
      },
    ));

    return completer.future;
  }

  Future<List<PostComment>> fetchComments(String postId) async {
    Completer<List<PostComment>> completer = Completer();

    postCommentService.retrieveComments(postId, (fetchedComments) {
      completer.complete(fetchedComments);

    }, (error) {
      print("Error fetching comments: $error");
      completer.complete([]);
    });

    return completer.future;
  }

  Future<List<PostLike>> fetchLikes(String postId) async {
    Completer<List<PostLike>> completer = Completer();

    postLikeService.getLikesForPost(postId, DataOperationCallback<List<PostLike>>(
      onSuccess: (likes) {
        completer.complete(likes);
      },
      onFailure: (error) {
        completer.completeError(error);
      },
    ));

    return completer.future;
  }

  void _deleteComment(String commentId) {
    postCommentService.removePostComment(commentId, () {
      setState(() {
        commentsFuture = fetchComments(widget.postId);
        commentCount--; // Decrease comment count
      });
      Utils.showMessage(context, "Comment deleted successfully.");
    }, (error) {
      Utils.showError(context, "Failed to delete comment: $error");
    });
  }

  void _deleteLike(PostLike like) {
    postLikeService.removeLike(like.postlikeId!, like.postId, OperationCallback(
      onSuccess: () {
        setState(() {
          likesFuture = fetchLikes(widget.postId);
          likeCount--; // Decrease like count
        });
        Utils.showMessage(context, "Like deleted successfully.");
      },
      onFailure: (error) {
        Utils.showError(context, "Failed to delete like: $error");
      },
    ));
  }
  void _deletePost() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Post"),
          content: Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                userPostService.deleteUserPost(widget.postId, OperationCallback(
                  onSuccess: () {
                    Navigator.of(context).pop(); // Close the dialog
                    if (userId != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => AdminUserDetailManageScreen(userId: userId!),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop(true);
                    }
                    Utils.showMessage(context, "Post deleted successfully.");
                  },
                  onFailure: (error) {
                    Navigator.of(context).pop(); // Close the dialog
                    Utils.showError(context, "Failed to delete post: $error");
                  },
                ));
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Detail"),
        actions: [
          if (SessionManager().getRoleType() != UserRole.moderator.role)
          TextButton(
            onPressed: _deletePost,
            style: TextButton.styleFrom(
              backgroundColor: Colors.purple, // Button color

              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding for button
            ),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: FutureBuilder<UserPost>(
        future: postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          UserPost post = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: (post.userprofilepicture != null && post.userprofilepicture!.isNotEmpty)
                            ? NetworkImage(post.userprofilepicture!)
                            : AssetImage('assets/user.png') as ImageProvider,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.username ?? 'Unknown User',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            post.location ?? '',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: post.uploadedImageUris.isNotEmpty
                      ? PageView.builder(
                    itemCount: post.uploadedImageUris.length,
                    itemBuilder: (context, imageIndex) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(post.uploadedImageUris[imageIndex]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  )
                      : Center(child: Text('No images available')),
                ),

                Text(
                  post.captiontext,
                  style: TextStyle(fontSize: 16),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      child: Row(
                        children: [
                          Image.asset(
                            likeCount > 0 ? 'assets/heart.png' : 'assets/like.png',
                            width: 20,
                            height: 20,
                          ), // Adjust size
                          SizedBox(width: 5),
                          Text(likeCount.toString(), style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),

                    SizedBox(width: 10), // Control space between chat icon and comment count
                    IconButton(
                      icon: Image.asset('assets/chat.png', width: 20, height: 20), // Adjust size
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),

                    // No space here, directly add comment count
                    Text(commentCount.toString(), style: TextStyle(fontSize: 14)),
                  ],
                ),

                Text(
                  Utils.getRelativeTime(post.createdon),
                  style: TextStyle(fontSize: 13),
                ),
                Divider(),
                SizedBox(height: 10),

                // Likes Section
                Text("Likes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                FutureBuilder<List<PostLike>>(
                  future: likesFuture,
                  builder: (context, likesSnapshot) {
                    if (likesSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (likesSnapshot.hasError) {
                      return Center(child: Text("Error loading likes"));
                    }

                    List<PostLike> likes = likesSnapshot.data!;
                    likeCount = likes.length; // Update like count

                    if (likes.isEmpty) {
                      return Center(child: Text('No likes yet.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: likes.length,
                      itemBuilder: (context, index) {
                        final like = likes[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(like.profilepicture ?? 'assets/user.png'),
                          ),
                          title: Text(like.username ?? 'Unknown User'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteLike(like),
                          ),
                        );
                      },
                    );
                  },
                ),

                // Comments Section
                Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                FutureBuilder<List<PostComment>>(
                  future: commentsFuture,
                  builder: (context, commentsSnapshot) {
                    if (commentsSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (commentsSnapshot.hasError) {
                      return Center(child: Text("Error loading comments"));
                    }

                    List<PostComment> comments = commentsSnapshot.data!;
                    commentCount = comments.length; // Update comment count

                    if (comments.isEmpty) {
                      return Center(child: Text('No comments yet.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(comment.userprofilepicture ?? 'assets/user.png'),
                          ),
                          title: Text(comment.username ?? 'Unknown User'),
                          subtitle: Text(comment.commenttext),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteComment(comment.postcommentId!),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
