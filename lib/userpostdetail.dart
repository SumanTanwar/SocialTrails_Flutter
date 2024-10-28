import 'package:flutter/material.dart';
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
          errorMessage = "Post load failed! Please try again later.";
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
            final post = userPosts[index];
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
                            post.username ?? 'User Name',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            post.location ?? '',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

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
                  child: PageView.builder(
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
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  post.captiontext,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        icon: Image.asset('assets/like.png'),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(post.likecount.toString(), style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),

                    Container(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        icon: Image.asset('assets/chat.png'),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(post.commentcount.toString(), style: TextStyle(fontSize: 14)),
                    Spacer(),

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
                  Utils.getRelativeTime(post.createdon),
                  style: TextStyle(fontSize: 13),
                ),
                Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
