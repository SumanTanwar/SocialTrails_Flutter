
import 'package:flutter/material.dart';
import 'package:socialtrailsapp/follounfollow.dart';
import 'package:socialtrailsapp/Utility/FollowService.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';

class FollowingsList extends StatefulWidget {
  final String userId;

  FollowingsList({required this.userId});

  @override
  _FollowingsListState createState() => _FollowingsListState();
}

class _FollowingsListState extends State<FollowingsList> {
  bool isLoading = true;
  List<Users> followingsList = [];

  @override
  void initState() {
    super.initState();
    loadFollowings();
  }

  void loadFollowings() {
    final followService = FollowService();
    followService.getFollowingDetails(widget.userId).then((result) {
      setState(() {
        followingsList = result;
        isLoading = false;
      });
    }).catchError((error) {
      print("Error loading followings: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followings List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : followingsList.isEmpty
            ? Center(child: Text("No followings found."))
            : ListView.builder(
          itemCount: followingsList.length,
          itemBuilder: (context, index) {
            final user = followingsList[index];
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
