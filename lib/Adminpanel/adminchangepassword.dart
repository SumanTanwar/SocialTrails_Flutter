import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialtrailsapp/Adminpanel/adminsetting.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/Utility/Utils.dart';
import 'package:socialtrailsapp/signin.dart';

class AdminChangePasswordScreen extends StatefulWidget {
  @override
  _AdminChangePasswordScreenState createState() => _AdminChangePasswordScreenState();
}

class _AdminChangePasswordScreenState extends State<AdminChangePasswordScreen> {
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
      Utils.showError(context, "Current Password is required");
      return;
    } else if (currentPwd.length < 8) {
      Utils.showError(context, "Current Password should be more than 8 characters");
      return;
    } else if (!Utils.isValidPassword(currentPwd)) {
      Utils.showError(context, "Current Password must contain at least one letter and one digit");
      return;
    }

    if (newPwd.isEmpty) {
      Utils.showError(context, "New Password is required");
      return;
    } else if (newPwd.length < 8) {
      Utils.showError(context, "New Password should be more than 8 characters");
      return;
    } else if (!Utils.isValidPassword(newPwd)) {
      Utils.showError(context, "New Password must contain at least one letter and one digit");
      return;
    }

    if (newPwd != confirmPwd) {
      Utils.showError(context, "New Passwords do not match");
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

        Utils.showMessage(context, "Password successfully changed! Sign in using new password");
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SigninScreen()));

      } catch (e) {
        Utils.showError(context,"Failed to change password! Please try again or check your current password.");
      }
    }
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
            const SizedBox(height: 10),
            Text("Enter your current password and new password to change.", style: TextStyle(fontSize: 16, color: Colors.purple)),
            const SizedBox(height: 10),

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
            const SizedBox(height: 10),

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
            const SizedBox(height: 10),

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
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text(
                  "Change Password",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminSettingsScreen()));
              },
              child: Text("Back", style: TextStyle(color: Colors.blue)),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
