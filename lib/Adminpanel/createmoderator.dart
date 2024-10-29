import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:socialtrailsapp/AdminPanel/AdminDashboard.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/main.dart';
import '../ModelData/UserRole.dart';
import '../ModelData/Users.dart';

class AdminCreateModeratorPage extends StatefulWidget {
  @override
  _AdminCreateModeratorPageState createState() => _AdminCreateModeratorPageState();
}

class _AdminCreateModeratorPageState extends State<AdminCreateModeratorPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _createModerator() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    if (_validateInputs(name, email)) {
      String temporaryPassword = "tempass123"; // Use a default temporary password
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: temporaryPassword,
        );

        User? currentUser = userCredential.user;

        if (currentUser != null) {
          String uid = currentUser.uid;

          Users user = Users(
            userId: uid,
            username: name,
            email: email,
            roles: UserRole.moderator.getRole(),
          );

          _userService.createUser(user, OperationCallback(
              onSuccess: () async {
                await _sendPasswordResetEmail(email);
                _clearInputs();
                _auth.signOut();

                // Navigate to the moderator list
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
                );
              },
              onFailure: (error) {
                _showError(error);
              }
          ));
        }
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  bool _validateInputs(String name, String email) {
    if (name.isEmpty) {
      _showError("Name is required");
      return false;
    }
    if (email.isEmpty) {
      _showError("Email is required");
      return false;
    }
    return true;
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showError("Password reset email sent to $email");
    } catch (e) {
      _showError("Failed to send password reset email.");
    }
  }

  void _clearInputs() {
    _nameController.clear();
    _emailController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create New Moderator")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 90),
            Image.asset('assets/socialtrails_logo.png', width: 150, height: 150),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: "Moderator username", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: "Moderator email", border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _createModerator,
              child: Text("Create Moderator", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(500, 50),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavigation(currentIndex: 4, onTap: (index) {
        // Handle navigation
      }),
    );
  }
}
