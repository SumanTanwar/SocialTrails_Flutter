import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/createpost.dart';
import 'package:socialtrailsapp/signin.dart';
import 'package:socialtrailsapp/usersetting.dart';
import 'package:socialtrailsapp/viewprofile.dart';


class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? username;
  String? email;
  String? bio;
  int postsCount = 0;
  int followersCount = 0;
  int followingsCount = 0;

  // get username => null;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    username = SessionManager().getUsername();
    email = SessionManager().getEmail();
    bio = SessionManager().getBio();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Retrieve user details
                String? username = SessionManager().getUsername() as String?;
                String? email = SessionManager().getEmail() as String?;

                // Show a message with user details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User: $username, Email: $email')),
                );
              },
              child: Text('Log In User'),
            ),
            ElevatedButton(
              onPressed: () {
                // Log out user

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserSettingsScreen()));
              },
              child: Text('User Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProfileScreen(
                      username: username ?? 'Guest',
                      bio: bio ?? 'No bio available',
                      email: email ?? '',
                      postsCount: postsCount,
                      followersCount: followersCount,
                      followingsCount: followingsCount,
                    ),
                  ),
                );
              },
              child: Text('View Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                // Log out user

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreatePostScreen()));
              },
              child: Text('Create Post'),
            ),
            ElevatedButton(
              onPressed: () {
                _auth.signOut();
             SessionManager().logoutUser();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SigninScreen()));
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),

    );
  }
}
