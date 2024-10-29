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

class SearchUserView extends StatefulWidget {
  @override
  _SearchUserViewState createState() => _SearchUserViewState();
}

class _SearchUserViewState extends State<SearchUserView> {
  List<Users> usersList = [];
  bool isLoading = true;
  final String currentUserID = SessionManager().getUserID().toString();

  @override
  void initState() {
    super.initState();
    loadUserList();
  }

  Future<void> loadUserList() async {
    try {
      final users = await UserService().getRegularUserList();
      setState(() {
        usersList = users.where((user) => user.userId != currentUserID).toList();
        isLoading = false;
      });
    } catch (error) {
      print("Error loading users: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Users')),
      body: Column(
        children: [
          SizedBox(height: 10),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (usersList.isEmpty)
            Center(child: Text("No users found."))
          else
            Expanded(
              child: ListView.builder(
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  final user = usersList[index];
                  return ListTile(
                    leading: user.profilepicture != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(user.profilepicture!),
                    )
                        : CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(user.username),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowUnfollowView(userId: user.userId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class FollowUnfollowView extends StatelessWidget {
  final String userId;

  FollowUnfollowView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Follow/Unfollow User')),
      body: Center(child: Text('Manage follow status for user $userId')),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SearchUserView()));
}
