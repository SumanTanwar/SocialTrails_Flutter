import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialtrailsapp/Interface/DataOperationCallback.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/main.dart';
import 'package:socialtrailsapp/viewprofile.dart';
import 'Interface/OperationCallback.dart';
import 'Utility/UserService.dart';
import 'Utility/Utils.dart';

class EditProfileScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const EditProfileScreen({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _imageFile;
  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _nameController.text = SessionManager().getUsername().toString();
    _emailController.text = SessionManager().getEmail().toString();
    _bioController.text = SessionManager().getBio().toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    String newName = _nameController.text.trim();
    String newBio = _bioController.text.trim();
    String currentName = SessionManager().getUsername().toString();
    String currentBio = SessionManager().getBio().toString();

    bool nameChanged = newName != currentName;
    bool bioChanged = newBio != currentBio;

    if (newName.isEmpty) {
      Utils.showError(context, "User name is required");
      return;
    }

    if (_imageFile != null) {
      await userService.uploadProfileImage(
        SessionManager().getUserID()!,
        _imageFile!,
        DataOperationCallback<String>(
          onSuccess: (imageUrl) {
            if (nameChanged || bioChanged) {
              _updateNameAndBio(imageUrl);
            } else {
              SessionManager().updateUserInfo(currentName, currentBio, imageUrl);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ViewProfileScreen()),
              );
            }
          },
          onFailure: (error) {
            Utils.showError(context, error);
          },
        ),
      );
    } else {
      if (nameChanged || bioChanged) {
        _updateNameAndBio(SessionManager().getImageUrl().toString());
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewProfileScreen()),
        );
      }
    }
  }

  void _updateNameAndBio(String imageUrl) {
    String newName = _nameController.text.trim();
    String newBio = _bioController.text.trim();

    userService.updateNameAndBio(SessionManager().getUserID()!, newName, newBio, OperationCallback(
      onSuccess: () {
        SessionManager().updateUserInfo(newName, newBio, imageUrl);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewProfileScreen()),
        );
      },
      onFailure: (error) {
        Utils.showError(context, "Update failed: $error");
      },
    ));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: Colors.purpleAccent,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (SessionManager().getImageUrl() != null && SessionManager().getImageUrl()!.isNotEmpty)
                            ? NetworkImage(SessionManager().getImageUrl()!)
                            : AssetImage('assets/user.png') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple,
                      ),
                      child: Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: Colors.black),
              _buildTextField(_nameController, "User Name", maxLength: 20),
              _buildTextField(
                _emailController,
                "Email",
                readOnly: true,
                maxLength: 100,
                hintStyle: TextStyle(color: Colors.grey),
                style: TextStyle(color: Colors.grey),
              ),
              _buildTextField(_bioController, "Bio", maxLength: 100),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
          currentIndex: widget.currentIndex,
          onTap: (index) {
            print("Tapped on: $index");
            widget.onTap(index);  // Call the passed onTap function to update index
          }
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool readOnly = false,
        int? maxLength,
        TextStyle? hintStyle,
        TextStyle? style,
      }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: label,
          hintStyle: hintStyle ?? TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple, width: 2),
          ),
        ),
        style: style ?? TextStyle(color: Colors.black),
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
          return null;
        },
      ),
    );
  }
}

