import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/Utility/Utils.dart';
import 'package:socialtrailsapp/viewprofile.dart';
import 'usersetting.dart'; // Adjust the import according to your structure

class EditProfileScreen extends StatefulWidget {

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;


  // Variable to hold the image URL
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = SessionManager().getUsername().toString();
    _bioController.text =  SessionManager().getEmail().toString();
    _imageUrl = SessionManager().getImageUrl();
  }

  void _updateProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String newName = _nameController.text.trim();
      String newBio = _bioController.text.trim();
      String imageUrl = _imageUrl ?? '';

      // Upload image to Firebase Storage if an image is selected
      if (_imageFile != null) {
        imageUrl = await _uploadImageToStorage();
      }

      // Update profile display name and other user data
      try {
        await user.updateProfile(displayName: newName);
        await _updateUserDataInDatabase(newName, newBio, imageUrl);
      } catch (error) {
        Utils.showError(context, "Failed to update profile: $error");
      }
    }
  }

  Future<String> _uploadImageToStorage() async {
    String userId = _auth.currentUser!.uid;
    File file = File(_imageFile!.path);

    // Create a reference to the Firebase Storage
    Reference ref = _storage.ref().child('userprofile/$userId');

    // Upload the image file
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    // Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _updateUserDataInDatabase(String name, String bio, String imageUrl) async {
    // String userId = _auth.currentUser?.uid ?? '';
    // try {
    //   await _database.child("users").child(userId).update({
    //     'username': name,
    //     'email': email, // Keep the email unchanged
    //     'bio': bio,
    //     'profile_image': imageUrl, // Save the profile image URL
    //   });
    //
    //   await SessionManager().updateUserInfo(name, email, bio, imageUrl); // Update the session manager
    //   _showSuccess("Profile updated successfully.");
    //
    //   // Redirect to user detail page with new values
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ViewProfileScreen(),
    //     ),
    //   );
    // } catch (error) {
    //   _showError("Failed to update user data in database: $error");
    // }
  }



  Widget _imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 40.0,
            backgroundImage: _imageFile == null
                ? (_imageUrl != null && _imageUrl!.isNotEmpty
                ? NetworkImage(_imageUrl!)
                : AssetImage('assets/user.png')) // Use NetworkImage if URL exists
                : FileImage(File(_imageFile!.path)) as ImageProvider,
          ),
          Positioned(
            bottom: 1.0,
            right: 2.0,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (builder) => bottomSheet()
                );
              },
              child: Icon(
                Icons.camera_alt,
                color: Colors.deepPurple,
                size: 35.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          Text("Choose profile photo",
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.image),
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                label: Text("Gallery"),
              ),
              TextButton.icon(
                icon: Icon(Icons.camera),
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                label: Text("Camera"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrl = SessionManager().getImageUrl();
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
              child: _imageProfile(),
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
              controller: TextEditingController(text: SessionManager().getEmail().toString()),
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
              child: ElevatedButton(
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
