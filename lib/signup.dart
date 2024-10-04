import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:socialtrailsapp/privacy_policy.dart';
import 'package:socialtrailsapp/signin.dart';

import 'Interface/OperationCallback.dart';
import 'ModelData/UserRole.dart';
import 'ModelData/Users.dart';
import 'Utility/UserService.dart';
import 'Utility/Utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService userService = UserService();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;



  Future<void> _registerUser() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Validate inputs
    if (username.isEmpty) {
      Utils.showError(context,"User name is required");
      return;
    }
    if (email.isEmpty) {
      Utils.showError(context,"Email is required");
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      Utils.showError(context,"Invalid email address");
      return;
    }
    if (password.isEmpty) {
      Utils.showError(context,"Password is required");
      return;
    }
    else if (password.length < 8) {
      Utils.showError(context,"Password should be more than 8 characters");
      return;
    }
    else if (!Utils.isValidPassword(password)) {
      Utils.showError(context,"Password must contain at least one letter and one digit.");
    return;
    }
    if (password != confirmPassword) {
      Utils.showError(context,"Passwords do not match");
      return;
    }
    if (!_termsAccepted) {
      Utils.showError(context,"Please accept terms and conditions");
      return;
    }
    try {
      // Create user with auth email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? currentUser = userCredential.user;

      if (currentUser != null) {
        // Send email verification
        await currentUser.sendEmailVerification();

        String uid = currentUser.uid;
        Users user = Users(userId: uid, username: username, email: email, roles: UserRole.user.getRole());

        // Create user in your database
        userService.createUser(user, OperationCallback(
          onSuccess: () {
            Utils.showMessage(context,"User registered successfully. Please verify your email.");
            _auth.signOut();

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SigninScreen()),
            );
          },
          onFailure: (errMessage) {
            Utils.showError(context,errMessage);
          },
        ));
      } else {
        Utils.showError(context,"Sign up failed! Please try again later.");
      }
    } catch (e) {
      Utils.showError(context,e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Add this widget
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/socialtrails_logo.png', width: 150, height: 150),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Start Your Journey",
                  style: TextStyle(fontSize: 20, color: Colors.purple, fontWeight: FontWeight.bold, fontFamily: 'RegularCursive',),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 15),
              _buildTextField(_usernameController, "User name"),
              _buildTextField(_emailController, "Email Address", keyboardType: TextInputType.emailAddress),
              _buildPasswordField(_passwordController, "Password", _passwordVisible, (value) {
                setState(() {
                  _passwordVisible = value;
                });
              }),
              _buildPasswordField(_confirmPasswordController, "Confirm Password", _confirmPasswordVisible, (value) {
                setState(() {
                  _confirmPasswordVisible = value;
                });
              }),
              Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (bool? value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                      });
                    },
                  ),
                  const Expanded(child: Text("I accept the terms and conditions!")),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity, // Make it full width
                child: ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Sign up", style: TextStyle(color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SigninScreen()));
                },
                child: const Text("Got a profile? Sign in"),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "By registering, I acknowledge that I have read and accept the General Terms and Conditions of Use and the ",
                    ),
                    TextSpan(
                      text: "privacy policy.",
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to the Privacy Policy page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PrivacyPolicy()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
// Helper method for text fields
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple, width: 2),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

// Helper method for password fields
  Widget _buildPasswordField(TextEditingController controller, String label, bool passwordVisible, Function(bool) onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              onToggle(!passwordVisible);
            },
          ),
        ),
        obscureText: !passwordVisible,
      ),
    );
  }
}
