import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/postlikelist.dart';
import 'Interface/DataOperationCallback.dart';
import 'ModelData/LikeResult.dart';
import 'ModelData/PostLike.dart';
import 'ModelData/UserPost.dart';
import 'Utility/PostLikeService.dart';
import 'Utility/Utils.dart';
import 'commentdialog.dart';

class PostItem extends StatefulWidget {
  final UserPost post;

  const PostItem({Key? key, required this.post}) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late bool isLiked;
  late int likeCount;
  late PostLikeService postLikeService;
  List<PostLike> likes = [];

  @override
  void initState() {
    super.initState();
    postLikeService = PostLikeService();
    isLiked = widget.post.isliked ?? false;
    likeCount = widget.post.likecount;
    _checkIfLiked();
    _loadLikes();
  }

  void _loadLikes() {
    postLikeService.getLikesForPost(widget.post.postId!, DataOperationCallback<List<PostLike>>(
      onSuccess: (result) {
        setState(() {
          likes = result;
        });
      },
      onFailure: (error) {
        print("Error fetching likes: $error");
      },
    ));
  }

  void _checkIfLiked() {
    String? userId = SessionManager().getUserID();
    postLikeService.getPostLikeByUserAndPostId(widget.post.postId!, userId!, DataOperationCallback<PostLike?>(
      onSuccess: (postLike) {
        setState(() {
          isLiked = postLike != null;
        });
      },
      onFailure: (error) {
        print("Error fetching like status: $error");
      },
    ));
  }

  void _toggleLike() {
    String? userId = SessionManager().getUserID();
    if (widget.post.postId != null) {
      postLikeService.likeAndUnlikePost(widget.post.postId!, userId!, DataOperationCallback<LikeResult>(
        onSuccess: (data) {
          setState(() {
            isLiked = data.isLike;
            likeCount = data.count;
          });
        },
        onFailure: (error) {
          print("Error liking/unliking post: $error");
        },
      ));
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
                    widget.post.username ?? 'UnKnown User',
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
              Container(
                width: 30,
                height: 30,
                child: IconButton(
                  icon: Image.asset('assets/menu-dots.png'),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
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
                  onPressed: () {},
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
