import 'package:flutter/material.dart';
import 'package:socialtrailsapp/AdminPanel/AdminDashboard.dart';
import 'package:socialtrailsapp/signin.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  _splashscreenState createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () async {
      final sessionManager = SessionManager();
      await sessionManager.init(); // Ensure SharedPreferences is initialized

      bool isLoggedIn = sessionManager.isLoggedIn();
      String? roleType = sessionManager.getRoleType();

      if (isLoggedIn) {
        // Get current user
        User? user = _auth.currentUser;

        // Check if user is admin and if their email is verified
        if (roleType == 'admin' && user != null && user.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else {
          // If not admin or email not verified, redirect to SignInScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SigninScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SigninScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/socialtrails_logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: const Text(
                'Share Your Story, Join the Journey',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RegularCursive',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

