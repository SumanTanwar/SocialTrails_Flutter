import 'dart:async';
import 'package:flutter/material.dart';
import '../ModelData/PostLike.dart';
import '../ModelData/UserRole.dart';
import 'Interface/OperationCallback.dart';
import 'Utility/PostLikeService.dart';
import 'Utility/SessionManager.dart';
import '../Interface/DataOperationCallback.dart';

class PostLikeList extends StatefulWidget {
  final String postId;
  final Function(PostLike) onLikeDeleted;

  const PostLikeList({Key? key, required this.postId, required this.onLikeDeleted}) : super(key: key);

  @override
  _PostLikeListState createState() => _PostLikeListState();
}

class _PostLikeListState extends State<PostLikeList> {
  late Future<List<PostLike>> _likesFuture;

  @override
  void initState() {
    super.initState();
    _likesFuture = _fetchLikes();
  }

  Future<List<PostLike>> _fetchLikes() {
    final completer = Completer<List<PostLike>>();
    PostLikeService().getLikesForPost(widget.postId, DataOperationCallback<List<PostLike>>(
      onSuccess: (likes) {
        completer.complete(likes);
      },
      onFailure: (error) {
        completer.completeError(error);
      },
    ));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostLike>>(
      future: _likesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load likes'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No likes yet.'));
        }

        final likes = snapshot.data!;
        final userRole = SessionManager().getRoleType();

        return ListView.builder(
          itemCount: likes.length,
          itemBuilder: (context, index) {
            final user = likes[index];
            final isAdminOrModerator = userRole == UserRole.admin.getRole() || userRole == UserRole.moderator.getRole();

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilepicture ?? 'assets/user.png'),
                ),
              ),
              title: Text(user.username ?? 'Unknown User'),
              trailing: isAdminOrModerator
                  ? IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _confirmDelete(context, user);
                },
              )
                  : null,
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, PostLike user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Like'),
          content: Text('Are you sure you want to delete the like from ${user.username}?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                PostLikeService().removeLike(user.postlikeId!, user.postId, OperationCallback(
                  onSuccess: () {
                    widget.onLikeDeleted(user);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Like deleted')));
                  },
                  onFailure: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete like')));
                  },
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
