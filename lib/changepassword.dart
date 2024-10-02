import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/Utility/Utils.dart';
import 'package:socialtrailsapp/signin.dart';
import 'package:socialtrailsapp/usersetting.dart';

class ChangePasswordScreen extends StatefulWidget {
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
    String currentPwd = _currentPwdController.text.trim();
    String newPwd = _newPwdController.text.trim();
    String confirmPwd = _confirmPwdController.text.trim();

    // Validation
    if (currentPwd.isEmpty) {
      _showError("Current Password is required");
      return;
    } else if (currentPwd.length < 8) {
      _showError("Current Password should be more than 8 characters");
      return;
    } else if (!Utils.isValidPassword(currentPwd)) {
      _showError("Current Password must contain at least one letter and one digit");
      return;
    }

    if (newPwd.isEmpty) {
      _showError("New Password is required");
      return;
    } else if (newPwd.length < 8) {
      _showError("New Password should be more than 8 characters");
      return;
    } else if (!Utils.isValidPassword(newPwd)) {
      _showError("New Password must contain at least one letter and one digit");
      return;
    }

    if (newPwd != confirmPwd) {
      _showError("New Passwords do not match");
      return;
    }

    // Change password logic
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Re-authenticate user
        String email = user.email!;
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPwd);

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPwd);

        _sessionManager.logoutUser(); // Logout user after password change
        await _auth.signOut();

        _showSuccess("Password successfully changed! Sign in using new password");
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SigninScreen()));

      } catch (e) {
        _showError("Failed to change password! Please try again.");
      }
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
                  icon: Icon(
                    _currentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
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
                  icon: Icon(
                    _newPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
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
                  icon: Icon(
                    _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
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

            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text("Change Password", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserSettingsScreen()));
              },
              child: Text("Back", style: TextStyle(color: Colors.blue)),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
