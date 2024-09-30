import 'package:flutter/material.dart';
import 'package:socialtrailsapp/signup.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  _splashscreenState createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  const SignUpScreen()),
      );
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
