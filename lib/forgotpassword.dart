
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

  void _resetPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showAlertDialog("Email is required");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showAlertDialog("Check your email to reset your password");
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context); // This will go back to the previous page (sign in)
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/socialtrails_logo.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 40),
            Text("Reset Password", style: TextStyle(fontSize: 24)),
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
                labelText: "Email",
                // fillColor: Colors.grey[200],
                // filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text("Reset", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 0),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to Sign In
              },
              child: Text("Back to Login", style: TextStyle(color: Colors.blue)),
            ),
            if (_showAlert)
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Text(
                  _alertMessage,
                  style: TextStyle(color: Colors.purple),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

