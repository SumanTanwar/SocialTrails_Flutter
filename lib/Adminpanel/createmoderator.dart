import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:socialtrailsapp/Adminpanel/adminmoeratorlist.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/signin.dart';
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

  String _generatedPassword = '';

  void _createModerator() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    if (_validateInputs(name, email)) {
      _generatedPassword = _generateRandomPassword(8);
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: _generatedPassword,
        );

        User? currentUser = userCredential.user;

        if (currentUser != null) {
          await currentUser.sendEmailVerification();

          String uid = currentUser.uid;


          Users user = Users(
            userId: uid,
            username: name,
            email: email,
            roles: UserRole.moderator.getRole(),
          );


          _userService.createUser(user, OperationCallback(
              onSuccess: () {
                print("User created successfully");
                _clearInputs();
                _auth.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminModeratorListScreen()),
                );
              },
              onFailure: (error) {
                _showError(error);
              }
          ));


          await _sendGeneratedPasswordEmail(email);
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

  String _generateRandomPassword(int length) {
    const String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#%^&*()";
    String password = List.generate(length, (index) => chars[(chars.length * (Random().nextDouble())).floor()]).join();
    return password;
  }

  Future<void> _sendGeneratedPasswordEmail(String email) async {
    String subject = "Your Moderator Account Creation";
    String message = "Hello,\n\nYour account has been created successfully.\n\n"
        "Here are your login details:\n"
        "Email: $email\n"
        "Password: $_generatedPassword\n\n"
        "Please change your password after your first login.\n\n"
        "Thank you!";


    print("Sending email to $email\nSubject: $subject\nMessage: $message");
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
     // appBar: AppBar(title: Text("Create New Moderator")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height:90),
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
              child: Text("Create Moderator", style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(500, 50),
              ),
            ),
            SizedBox(height: 15),
            if (_generatedPassword.isNotEmpty) ...[
              Text("Generated Password: $_generatedPassword"),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generatedPassword));
                  _showError("Password copied to clipboard");
                },
                child: Text("Copy Password"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
