import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/ModelData/Report.dart';
import 'package:socialtrailsapp/Utility/ReportService.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/Utility/UserPostService.dart';
import 'package:socialtrailsapp/postlikelist.dart';
import 'package:socialtrailsapp/userpostedit.dart';
import 'Interface/DataOperationCallback.dart';
import 'ModelData/LikeResult.dart';
import 'ModelData/PostLike.dart';
import 'ModelData/UserPost.dart';
import 'Utility/PostLikeService.dart';
import 'Utility/Utils.dart';
import 'commentdialog.dart';


class PostItem extends StatefulWidget {
  final UserPost post;
  final VoidCallback onDelete;

  const PostItem({Key? key, required this.post, required this.onDelete}) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late bool isLiked;
  late int likeCount;
  late PostLikeService postLikeService;
  late String postId;
  List<PostLike> likes = [];

  @override
  void initState() {
    super.initState();
    postLikeService = PostLikeService();
    isLiked = widget.post.isliked ?? false;
    likeCount = widget.post.likecount;
    postId = widget.post.postId ?? "";
    _checkIfLiked();
    _loadLikes();
  }

  void _loadLikes() {
    postLikeService.getLikesForPost(
      widget.post.postId!,
      DataOperationCallback<List<PostLike>>(
        onSuccess: (result) {
          setState(() {
            likes = result;
          });
        },
        onFailure: (error) {
          print("Error fetching likes: $error");
        },
      ),
    );
  }

  void _checkIfLiked() {
    String? userId = SessionManager().getUserID();
    postLikeService.getPostLikeByUserAndPostId(
      widget.post.postId!,
      userId!,
      DataOperationCallback<PostLike?>(
        onSuccess: (postLike) {
          setState(() {
            isLiked = postLike != null;
          });
        },
        onFailure: (error) {
          print("Error fetching like status: $error");
        },
      ),
    );
  }

  void _toggleLike() {
    String? userId = SessionManager().getUserID();
    if (widget.post.postId != null) {
      postLikeService.likeAndUnlikePost(
        widget.post.postId!,
        userId!,
        DataOperationCallback<LikeResult>(
          onSuccess: (data) {
            setState(() {
              isLiked = data.isLike;
              likeCount = data.count;
            });
          },
          onFailure: (error) {
            print("Error liking/unliking post: $error");
          },
        ),
      );
    } else {
      print("Post ID is null.");
    }
  }

  void _showLikesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Likes'),
          content: Container(
            width: double.maxFinite,
            height: 450,
            child: PostLikeList(
              postId: widget.post.postId!,
              onLikeDeleted: (PostLike deletedLike) {
                setState(() {
                  likes.removeWhere((like) => like.postlikeId == deletedLike.postlikeId);
                });
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showCommentsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CommentDialog(
          postId: widget.post.postId!,
          userId: SessionManager().getUserID()!,
          onCommentCountUpdated: (newCount) {
            setState(() {
              widget.post.commentcount = newCount;
            });
          },
        );
      },
    );
  }

  void openReportDialog(BuildContext context, String postId) {
    String reason = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0),
          title: Text(
            'Report Issue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Why are you reporting?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'Your report is anonymous. If someone is in immediate danger, call the local emergency service.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 8),
              TextField(
                maxLines: 5,
                onChanged: (value) {
                  reason = value;
                },
                decoration: InputDecoration(
                  hintText: 'Describe the issue here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(8.0),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (reason.isNotEmpty) {
                  reportPost(postId, reason);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please provide a reason for reporting.')),
                  );
                }
              },
              child: Text('Report'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void reportPost(String postId, String reason) {
    Report report = Report(
      createdon: DateTime.now().toString(),
      reason: reason,
      reportedid: postId,
      reporterid: SessionManager().getUserID()!,
      reporttype: 'post',
      status: 'pending',
    );

    ReportService reportService = ReportService();

    reportService.addReport(
      report,
      OperationCallback(
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report submitted successfully!')),
          );
        },
        onFailure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Something went wrong! Please try again later.')),
          );
        },
      ),
    );
  }

  void _confirmDeletePost() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                UserPostService().deleteUserPost(widget.post.postId!, OperationCallback(
                  onSuccess: () {
                    Navigator.of(context).pop(); // Close the dialog
                    widget.onDelete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Post deleted successfully!')),
                    );
                  },
                  onFailure: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete post. Please try again.')),
                    );
                  },
                ));
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: (widget.post.userprofilepicture != null && widget.post.userprofilepicture!.isNotEmpty)
                    ? NetworkImage(widget.post.userprofilepicture!)
                    : AssetImage('assets/user.png') as ImageProvider,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.username ?? 'Unknown User',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.post.location ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (SessionManager().getUserID() == widget.post.userId)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  print('Selected: $value');
                  if (value == 'edit') {
                    if (postId != null) {

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserPostEditScreen(postDetailId: postId),
                        ),
                      );
                    } else {
                      // Handle the case where postId is null
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unable to edit. Post ID is missing.')),
                      );
                    }
                  }else
                  if (value == 'delete') {
                    _confirmDeletePost();
                  }

                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: widget.post.uploadedImageUris.isNotEmpty
              ? PageView.builder(
            itemCount: widget.post.uploadedImageUris.length,
            itemBuilder: (context, imageIndex) {
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.post.uploadedImageUris[imageIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          )
              : Center(child: Text('No images available')),
        ),
        SizedBox(height: 8),
        Text(
          widget.post.captiontext,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              child: IconButton(
                icon: Image.asset(isLiked ? 'assets/heart.png' : 'assets/like.png'),
                onPressed: _toggleLike,
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: _showLikesDialog,
              child: Text(likeCount.toString(), style: TextStyle(fontSize: 14)),
            ),
            SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              child: IconButton(
                icon: Image.asset('assets/chat.png'),
                onPressed: _showCommentsDialog,
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(width: 4),
            Text(widget.post.commentcount.toString(), style: TextStyle(fontSize: 14)),
            Spacer(),
            if (SessionManager().getUserID() != widget.post.userId)
              Container(
                width: 30,
                height: 30,
                child: IconButton(
                  icon: Icon(Icons.warning),
                  onPressed: () {
                    openReportDialog(context, widget.post.postId!);
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        Text(
          Utils.getRelativeTime(widget.post.createdon),
          style: TextStyle(fontSize: 13),
        ),
        Divider(),
      ],
    );
  }
}
