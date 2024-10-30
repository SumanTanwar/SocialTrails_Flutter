import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';
import 'package:socialtrailsapp/main.dart';
import '../Interface/DataOperationCallback.dart';
import '../ModelData/UserPost.dart';
import '../Utility/UserPostService.dart';
import '../Utility/Utils.dart';

class FollowUnfollowView extends StatefulWidget {
  final String userId;

  FollowUnfollowView({required this.userId});

  @override
  _FollowUnfollowViewState createState() => _FollowUnfollowViewState();
}

class _FollowUnfollowViewState extends State<FollowUnfollowView> {
  Users? user;
  bool isLoading = true;
  final UserService userService = UserService();
  final UserPostService userPostService = UserPostService();
  List<String> _postImages = [];
  int postsCount = 0;


  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    user = await userService.adminGetUserByID(widget.userId);
    _fetchUserPosts(widget.userId);
    setState(() {
      isLoading = false;
    });
  }



  Future<void> _fetchUserPosts(String userId) async {
    await userPostService.getAllUserPost(userId, DataOperationCallback<List<UserPost>>(
      onSuccess: (posts) {
        setState(() {
          _postImages = posts
              .map((post) => (post.uploadedImageUris?.isNotEmpty == true)
              ? post.uploadedImageUris![0]
              : null)
              .where((image) => image != null)
              .cast<String>()
              .toList();

          postsCount = _postImages.length;
        });
      },
      onFailure: (error) {
        print("Failed to fetch posts: $error");
      },
    ));
  }

  void _followUser() {
    // Add your follow logic here, e.g., API call to follow the user
    print("Followed user with ID");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: const EdgeInsets.only(top: 50),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: (user?.profilepicture != null && user!.profilepicture.isNotEmpty)
                            ? NetworkImage(user!.profilepicture)
                            : AssetImage('assets/user.png') as ImageProvider,
                      ),
                      SizedBox(height: 5),
                      Text(
                        user?.username ?? 'Unknown User',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  ProfileStat(count: '0', label: 'Posts'), // You may want to fetch this data as well
                  SizedBox(width: 15),
                  ProfileStat(count: '0', label: 'Followers'), // You may want to fetch this data as well
                  SizedBox(width: 15),
                  ProfileStat(count: '0', label: 'Followings'), // You may want to fetch this data as well
                ],
              ),
              SizedBox(height: 5),
              UserDetailText(label: user?.bio ?? ''),
              SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _followUser, // Your save function here
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Button color
                      padding: const EdgeInsets.symmetric(vertical: 10.0), // Vertical padding
                      textStyle: const TextStyle(fontSize: 16), // Text style
                    ),
                    child: Text('Follow', style: TextStyle(color: Colors.white)), // Button text
                  ),
                ),
              ),

              _postImages.isNotEmpty
                  ? Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                  ),
                  itemCount: _postImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        image: DecorationImage(
                          image: NetworkImage(_postImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              )
                  : Text("No posts available"),

            ],
          ),
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String count;
  final String label;

  ProfileStat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ],
    );
  }
}

class UserDetailText extends StatelessWidget {
  final String label;

  UserDetailText({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 10),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }
}
