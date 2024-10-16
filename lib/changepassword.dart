import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/main.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ChangePasswordScreen({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SessionManager _sessionManager = SessionManager();

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  void _changePassword() async {
    String currentPassword = _currentPwdController.text.trim();
    String newPassword = _newPwdController.text.trim();
    String confirmPassword = _confirmPwdController.text.trim();

    if (newPassword != confirmPassword) {
      _showError("New password and confirm password do not match.");
      return;
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
        _showSuccess("Password changed successfully.");
        Navigator.pop(context); // Go back to previous screen
      }
    } catch (e) {
      _showError("Failed to change password: ${e.toString()}");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: Colors.red))));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: Colors.green))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 70),
            Image.asset('assets/socialtrails_logo.png', width: 150, height: 150),
            const SizedBox(height: 10),
            Text("Change Password", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Enter your current password and new password to change.", style: TextStyle(fontSize: 16, color: Colors.purple)),
            SizedBox(height: 10),

            // Current Password Field
            TextField(
              controller: _currentPwdController,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_currentPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _currentPasswordVisible = !_currentPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_currentPasswordVisible,
            ),
            SizedBox(height: 10),

            // New Password Field
            TextField(
              controller: _newPwdController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_newPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _newPasswordVisible = !_newPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_newPasswordVisible,
            ),
            SizedBox(height: 10),

            // Confirm New Password Field
            TextField(
              controller: _confirmPwdController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_confirmPasswordVisible,
            ),
            SizedBox(height: 20),

            // Change Password Button
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text("Change Password", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
          currentIndex: widget.currentIndex,
          onTap: (onTap){
            widget.onTap(onTap);  // Call the passed onTap function to update index
          }
      ),
    );
  }
}


