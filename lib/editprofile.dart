import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/viewprofile.dart';
import 'usersetting.dart'; // Adjust the import according to your structure

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String bio;

  EditProfileScreen({required this.name, required this.email, required this.bio});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _bioController.text = widget.bio;
  }

  void _updateProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String newName = _nameController.text.trim();
      String newBio = _bioController.text.trim();

      // Update profile display name
      try {
        await user.updateProfile(displayName: newName);
        await _updateUserDataInDatabase(newName, widget.email, newBio);
      } catch (error) {
        _showError("Failed to update profile: $error");
      }
    }
  }

  Future<void> _updateUserDataInDatabase(String name, String email, String bio) async {
    String userId = _auth.currentUser?.uid ?? '';
    try {
      await _database.child("users").child(userId).update({
        'username': name,
        'email': email, // Keep the email unchanged
        'bio': bio,
      });

      SessionManager().updateUserInfo(name, email, bio); // Update the session manager
      _showSuccess("Profile updated successfully.");

      int postsCount = 0;
      int followersCount = 0;
      int followingsCount = 0;

      // Redirect to user detail page with new values
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ViewProfileScreen(
            username: name,
            email: email,
            bio: bio,
            postsCount: postsCount,
            followersCount: followersCount,
            followingsCount: followingsCount,),
        ),
      );
    } catch (error) {
      _showError("Failed to update user data in database: $error");
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 150),
              padding: EdgeInsets.all(12),
              child: Row( mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/user.png'),
                  ),

                ],
              ),
            ),
            SizedBox(height: 10),
            Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            // Display email but not editable
            TextField(
              controller: TextEditingController(text: widget.email),
              decoration: InputDecoration(labelText: "Email"),
              enabled: false,
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: "Bio"),
            ),
            SizedBox(height: 20),
Container(
    width: double.infinity,
  child:  ElevatedButton(
    onPressed: _updateProfile,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      textStyle: const TextStyle(fontSize: 16),
    ),
    child: const Text("Save", style: TextStyle(color: Colors.white)),
  ),

),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserSettingsScreen()));
              },
              child: Text("Back", style: TextStyle(color: Colors.blue)),
            ),



          ],
        ),
      ),
    );
  }
}
