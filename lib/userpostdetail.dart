import 'package:flutter/material.dart';
import 'package:socialtrailsapp/postitem.dart';
import 'Interface/DataOperationCallback.dart';
import 'ModelData/UserPost.dart';
import 'Utility/SessionManager.dart';
import 'Utility/UserPostService.dart';
import 'Utility/Utils.dart';

class UserPostDetailScreen extends StatefulWidget {
  final String postDetailId;

  UserPostDetailScreen({Key? key, required this.postDetailId}) : super(key: key);

  @override
  _UserPostDetailScreenState createState() => _UserPostDetailScreenState();
}

class _UserPostDetailScreenState extends State<UserPostDetailScreen> {
  final UserPostService userPostService = UserPostService();
  List<UserPost> userPosts = [];
  bool isLoading = true;
  String? errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadPostDetails();
  }

  void loadPostDetails() {
    String userId = SessionManager().getUserID()!;
    userPostService.getAllUserPostDetail(userId, DataOperationCallback<List<UserPost>>(
      onSuccess: (postList) {
        setState(() {
          userPosts = postList;
          isLoading = false;
          scrollToPost(widget.postDetailId);
        });
      },
      onFailure: (error) {
        setState(() {
          Utils.showError(context, "Post load failed! Please try again later.");
          isLoading = false;
        });
      },
    ));
  }

  void scrollToPost(String postDetailId) {
    int index = userPosts.indexWhere((post) => post.postId == postDetailId);
    if (index != -1) {
      _scrollController.animateTo(
        index * 200.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: userPosts.length,
          itemBuilder: (context, index) {
            return PostItem(
              key: ValueKey(userPosts[index].postId),
              post: userPosts[index],
              onDelete: () {
                loadPostDetails();
              },
            );
          },
        ),
      ),
    );
  }
}
