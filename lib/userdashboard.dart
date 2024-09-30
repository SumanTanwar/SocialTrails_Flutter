import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/signin.dart';


class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                String? username = SessionManager().getUsername();
                String? email = SessionManager().getEmail();

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
                SessionManager().logoutUser();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SigninScreen()));
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),

    );
  }
}
