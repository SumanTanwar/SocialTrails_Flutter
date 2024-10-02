import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordView extends StatefulWidget {
  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showAlert = false;
  String _alertMessage = '';
  bool _navigateToSignIn = false;

  void _resetPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showAlertDialog("Email is required");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showAlertDialog("Check your email to reset your password");
      setState(() {
        _navigateToSignIn = true;
      });
    } catch (e) {
      _showAlertDialog("Failed to send reset email: ${e.toString()}");
    }
  }

  void _showAlertDialog(String message) {
    setState(() {
      _alertMessage = message;
      _showAlert = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/socialtrails_logo.png', // Adjust the asset path
              width: 200,
              height: 200,
            ),
            SizedBox(height: 40),
            Text(
              "Reset Password",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              "Enter your email address to receive a link to reset your password",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                fillColor: Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text("Reset"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 0), // Set to fill the width
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to Sign In
              },
              child: Text("Back to Login", style: TextStyle(color: Colors.blue)),
            ),
            Spacer(),
          ],
        ),
      ),
      // Show alert dialog if needed
      floatingActionButton: _showAlert
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _showAlert = false;
          });
        },
        child: Icon(Icons.close),
        backgroundColor: Colors.red,
      )
          : null,
      // Alert dialog for messages
      bottomSheet: _showAlert
          ? Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Text(
          _alertMessage,
          style: TextStyle(color: Colors.black),
        ),
      )
          : null,
    );
  }
}
