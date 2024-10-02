import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/signin.dart';

class UserSettingsScreen extends StatefulWidget {
  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  late TextEditingController _usernameController;
  late bool _notificationsEnabled;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final UserService _userService = UserService();

  @override
  void initState() {

    super.initState();

    _usernameController = TextEditingController(text: SessionManager().getUsername() ?? "User");
    _notificationsEnabled = SessionManager().getNotificationStatus();
  }



  void _logout() {
    SessionManager().logoutUser();
    _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Settings")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile section
            Container(
              margin: EdgeInsets.only(top: 40),
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/user.png'),
                  ),
                  SizedBox(width: 12),
                  Text(
                    _usernameController.text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Description Text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                "Manage your account information and preferences to personalize your experience.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Notification Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Activate Notification",
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    SessionManager().setNotificationStatus(value);
                  },
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey),

            GestureDetector(
              onTap: () {
                // Handle Change Password
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Change Password",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            GestureDetector(
              onTap: () {
                // Handle Edit Profile
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            GestureDetector(
              onTap: () {
                // Handle Delete Profile
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Delete Profile",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            GestureDetector(
              onTap: _logout,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Log Out",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
