import 'package:flutter/material.dart';
import '../AdminPanel/adminusermanage.dart';
import '../ModelData/Users.dart';
import '../Utility/UserService.dart';

class AdminUserListScreen extends StatefulWidget {
  @override
  _AdminUserListScreenState createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final UserService userService = UserService();
  List<Users> usersList = [];

  @override
  void initState() {
    super.initState();
    loadUserList();
  }

  void loadUserList() {
    userService.getRegularUserList().then((data) {
      setState(() {
        usersList = data;
      });
      print("Users list updated with ${usersList.length} users");
    }).catchError((error) {
      print("Error loading users: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Regular Users",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminUserDetailManageScreen(userId: '')),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, size: 30),
                      SizedBox(width: 8),
                      Text(
                        "Moderator",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: usersList.isEmpty
                  ? Center(child: Text("No users found."))
                  : ListView.builder(
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  final user = usersList[index];
                  return ListTile(
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminUserDetailManageScreen(userId: user.userId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
