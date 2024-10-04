import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Interface/OperationCallback.dart';
import 'ModelData/UserPost.dart';
import 'Utility/SessionManager.dart';
import 'Utility/UserPostService.dart';
import 'Utility/Utils.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles = [];
  final TextEditingController _captionController = TextEditingController();
  final UserPostService _userPostService = UserPostService();

  Future<void> _pickImage() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _imageFiles?.addAll(selectedImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles?.removeAt(index);
    });
  }

  void _sharePost() {
    String caption = _captionController.text.trim();
    if (caption.isEmpty) {
      Utils.showError(context, "Caption cannot be empty.");
      return;
    }
    if (_imageFiles!.isEmpty) {
      Utils.showError(context, "Please add at least one image.");
      return;
    }

    List<Uri> imageUris = _imageFiles!.map((file) => Uri.file(file.path)).toList();
    String? userId = SessionManager().getUserID();
    if (userId == null) {
      Utils.showError(context, "User ID cannot be null.");
      return;
    }

    UserPost userPost = UserPost(
      userId: userId,
      captionText: caption,
      imageUris: imageUris,
    );

    _userPostService.createPost(userPost, OperationCallback(
      onSuccess: () {
        Utils.showMessage(context, "Post created successfully!");
      },
      onFailure: (error) {
        Utils.showError(context, error.toString());
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/socialtrails_logo.png'),
                  ),
                  SizedBox(width: 10),
                  Text(
                    SessionManager().getUsername() ?? "Unknown User",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _captionController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Write a caption...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey[600]),
              Row(
                children: [
                  Icon(Icons.location_on, size: 30),
                  SizedBox(width: 10),
                  Text(
                    "Tag Location",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey[600]),
              Container(
                margin: EdgeInsets.only(top: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFiles!.isEmpty
                    ? SizedBox()
                    : Column(
                  children: [
                    Container(
                      height: 200, // Adjust height here
                      child: PageView.builder(
                        itemCount: _imageFiles!.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                File(_imageFiles![index].path),
                                fit: BoxFit.contain, // Change to BoxFit.contain
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () => _removeImage(index),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/photo.png',
                          width: 38,
                          height: 38,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _sharePost,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/share.png',
                          width: 38,
                          height: 38,
                        ),
                      ),
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
}
