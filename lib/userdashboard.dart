import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/postitem.dart';
import 'Interface/DataOperationCallback.dart';
import 'ModelData/UserPost.dart';
import 'Utility/UserPostService.dart';
import 'notifications.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? username;
  bool isLoading = true;
  List<UserPost> posts = [];
  final UserPostService userPostService = UserPostService();

  @override
  void initState() {
    super.initState();
    username = SessionManager().getUsername();
    _fetchUserPost();
  }

  void _fetchUserPost() {
    String userId = SessionManager().getUserID()!;
    userPostService.retrievePostsForFollowedUsers(userId, DataOperationCallback<List<UserPost>>(
      onSuccess: (postList) {
        setState(() {
          posts = postList ?? [];
          isLoading = false;
        });
      },
      onFailure: (error) {
        setState(() {
          posts = [];
          isLoading = false;
        });
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: (SessionManager().getImageUrl() != null && SessionManager().getImageUrl()!.isNotEmpty)
                            ? NetworkImage(SessionManager().getImageUrl()!)
                            : AssetImage('assets/user.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      username ?? "Unknown",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : posts.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "You haven't followed anyone yet. Start following users to view their posts in your feed.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostItem(
                    key: ValueKey(posts[index].postId),
                    post: posts[index],
                    onDelete: () {

                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
