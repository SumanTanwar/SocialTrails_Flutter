import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socialtrailsapp/Utility/PostImagesService.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/userpostdetail.dart';
import 'Interface/DataOperationCallback.dart';
import 'Utility/LocationPicker.dart'; // Adjust to your actual path
import 'ModelData/UserPost.dart';
import 'Utility/UserPostService.dart';
import 'Utility/Utils.dart';
import 'Interface/OperationCallback.dart';

class UserPostEditScreen extends StatefulWidget {
  final String postDetailId;

  UserPostEditScreen({required this.postDetailId});

  @override
  _UserPostEditScreenState createState() => _UserPostEditScreenState();
}

class _UserPostEditScreenState extends State<UserPostEditScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles = [];
  final TextEditingController _captionController = TextEditingController();
  final UserPostService _userPostService = UserPostService();
  final PostImagesService _postImagesService = PostImagesService();
  UserPost? userPost;
  String _selectedLocation = "Tag Location";
  double? _latitude, _longitude;

  @override
  void initState() {
    super.initState();
    _fetchPostDetails(widget.postDetailId);
  }

  void _fetchPostDetails(String postId) {
    _userPostService.getPostByPostId(postId, DataOperationCallback<UserPost>(
      onSuccess: (data) {
        setState(() {
          userPost = data;
          _captionController.text = userPost?.captiontext ?? "";
          _selectedLocation = userPost?.location ?? "Tag Location";
          _latitude = userPost?.latitude;
          _longitude = userPost?.longitude;

        });
      },
      onFailure: (errMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMessage)));
      },
    ));
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  void _showLocationPicker() async {
    await _checkLocationPermission();
    final selectedLocation = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationPicker(),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation['address'];
        _latitude = selectedLocation['latitude'];
        _longitude = selectedLocation['longitude'];
      });
    }
  }

  void _editPost() {
    String caption = _captionController.text.trim();
    if (caption.isEmpty) {
      Utils.showError(context, "Caption cannot be empty.");
      return;
    }
    if (_selectedLocation.isEmpty || _selectedLocation == "Tag Location") {
      Utils.showError(context, "Please tag the location.");
      return;
    }

    if (userPost != null) {
      userPost!.captiontext = caption;
      userPost!.location = _selectedLocation;
      userPost!.latitude = _latitude;
      userPost!.longitude = _longitude;

      _userPostService.updateUserPost(userPost!, OperationCallback(
        onSuccess: () {
          Utils.showMessage(context, "Post updated successfully!");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => UserPostDetailScreen(postDetailId: userPost!.postId!,),
            ),
          );
          Navigator.pop(context);
        },
        onFailure: (error) {
          Utils.showError(context, error.toString());
        },
      ));
    }
  }

  void _removeImage(int index) {
    // Get the image path to delete, ensuring it's not null
    String? imagePath = userPost!.uploadedImageUris[index] as String?;

    if (imagePath != null) {
      // Remove from the local list
      setState(() {

        userPost!.uploadedImageUris.removeAt(index); // Remove from the post data as well
      });

      // Delete from the database
      _postImagesService.deleteImage(userPost!.postId!, imagePath, OperationCallback(
        onSuccess: () {
          Utils.showMessage(context, "Image removed successfully!");
        },
        onFailure: (error) {
          Utils.showError(context, error.toString());
        },
      ));
    } else {
      Utils.showError(context, "Image path is null.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: (SessionManager().getImageUrl() != null && SessionManager().getImageUrl()!.isNotEmpty)
                        ? NetworkImage(SessionManager().getImageUrl()!)
                        : AssetImage('assets/user.png') as ImageProvider,
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(SessionManager().getUsername() ?? "Unknown User", style: TextStyle(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: _showLocationPicker,
                      child: Row(
                        children: [
                          Text(
                            _selectedLocation,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                  //  Text(_selectedLocation, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 100,
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
            // Location Picker Section

            Container(
              height: 200,
              child: userPost!.uploadedImageUris.isNotEmpty
                  ? PageView.builder(
                itemCount: userPost!.uploadedImageUris.length,
                itemBuilder: (context, imageIndex) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(userPost!.uploadedImageUris[imageIndex]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (userPost!.uploadedImageUris.length > 1) // Show remove button only if more than one image
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _removeImage(imageIndex), // Call your remove function
                        ),
                    ],
                  );
                },
              )
                  : Center(child: Text('No images available')),
            ),
            SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Redirect to UserPostDetailScreen when cancel button is pressed
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => UserPostDetailScreen(postDetailId: userPost!.postId!),
                      ),
                    );
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: _editPost,
                  child: Text("Done"),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
