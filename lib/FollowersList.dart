// FollowersList.dart
import 'package:flutter/material.dart';
import 'package:socialtrailsapp/follounfollow.dart';
import 'package:socialtrailsapp/Utility/FollowService.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';

class FollowersList extends StatefulWidget {
  final String userId;

  FollowersList({required this.userId});

  @override
  _FollowersListState createState() => _FollowersListState();
}

class _FollowersListState extends State<FollowersList> {
  bool isLoading = true;
  List<Users> followersList = [];

  @override
  void initState() {
    super.initState();
    loadFollowers();
  }

  void loadFollowers() {
    final followService = FollowService();
    followService.getFollowersDetails(widget.userId).then((result) {
      setState(() {
        followersList = result;
        isLoading = false;
      });
    }).catchError((error) {
      print("Error loading followers: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : followersList.isEmpty
            ? Center(child: Text("No followers found."))
            : ListView.builder(
          itemCount: followersList.length,
          itemBuilder: (context, index) {
            final user = followersList[index];
            return ListTile(
              leading: user.profilepicture != null
                  ? ClipOval(
                child: Image.network(
                  user.profilepicture!,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                          child: CircularProgressIndicator());
                    }
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.person, size: 50),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(Icons.person, size: 50),
              title: Text(user.username),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowUnfollowView(
                      userIdToFollow: user.userId,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
