import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialtrailsapp/changepassword.dart';
import 'package:socialtrailsapp/signin.dart';

class AdminSettingsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) {
    _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center the logo and "Admin" text in the middle
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/socialtrails_logo.png',
                    width: 100, // Adjust size as necessary
                    height: 100,
                  ),
                  SizedBox(height: 10), // Space below the logo

                  Text(
                    'Admin',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Add some space after logo and "Admin"

            // "Admin Settings" header in bold, aligned to the left
            Text(
              'Admin Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Create Moderator
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Create Moderator",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Change Password
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Change Password",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Log Out
            GestureDetector(
              onTap: () => _logout(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
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
