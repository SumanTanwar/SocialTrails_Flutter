import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/main.dart';
import 'package:socialtrailsapp/signin.dart';
import 'Utility/Utils.dart';
import 'changepassword.dart';
import '../Interface/OperationCallback.dart';
import 'editprofile.dart';

class UserSettingsScreen extends StatefulWidget {
  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  late TextEditingController _usernameController;
  late bool _notificationsEnabled;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();



  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: SessionManager().getUsername() ?? "User",
    );
    _notificationsEnabled = SessionManager().getNotificationStatus();
  }

  void _logout() {
    SessionManager().logoutUser();
    _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(
          currentIndex: 4,
          onTap: (index){
            setState(() {
              var  _currentIndex = index; // Update the state with the tapped index
            });
          },
        ),
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          onTap: (index) {},
          currentIndex: 4,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Account"),
          content: Text("Are you sure you want to delete your account?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                User? user = _auth.currentUser;

                if (user != null) {
                  String userId = SessionManager().getUserID() ?? '';

                  // First delete user profile from database
                  _userService.deleteUserProfile(userId, OperationCallback(
                    onSuccess: () async {
                      // After successful profile deletion, delete from Firebase Auth
                      try {
                        await user.delete(); // Delete the user from Firebase Auth
                        Utils.showMessage(context, "Account deleted successfully.");

                        // Clear credentials and log out
                        Utils.removeRememberCredentials();
                        SessionManager().logoutUser();
                        _auth.signOut();

                        // Navigate to Sign In screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SigninScreen()),
                        );
                      } catch (e) {
                        Utils.showError(context, "Failed to delete account from Firebase Auth: ${e.toString()}");
                      }
                    },
                    onFailure: (errorMessage) {
                      Utils.showError(context, "Failed to delete account: $errorMessage");
                    },
                  ));
                } else {
                  Utils.showError(context, "User not found. Please log in again.");
                }
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrl = SessionManager().getImageUrl();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile section
            Container(
              margin: EdgeInsets.only(top: 40),
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl) // Use NetworkImage for URL
                        : AssetImage('assets/user.png') as ImageProvider, // Default image
                  ),
                  SizedBox(width: 12),
                  Text(
                    _usernameController.text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Description Text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                "Manage your account information and preferences to personalize your experience.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Notification Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Activate Notification",
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });

                    String? userId = SessionManager().getUserID();
                    if (userId != null) {
                      _userService.setNotification(userId, value, OperationCallback(
                        onSuccess: () {
                          SessionManager().setNotificationStatus(value);
                          Utils.showMessage(context, "Notifications turned ${value ? 'ON' : 'OFF'}");
                        },
                        onFailure: (errorMessage) {
                          Utils.showError(context, "Failed to update notification status: $errorMessage");
                          setState(() {
                            _notificationsEnabled = !value; // Roll back the switch if failed
                          });
                        },
                      ));
                    } else {
                      Utils.showError(context, "User ID not found. Please log in again.");
                    }
                  },
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Change Password
            GestureDetector(
              onTap: _navigateToChangePassword,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Change Password",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Edit Profile
            GestureDetector(
              onTap: () {
                User? user = _auth.currentUser;
                if (user != null) {
                  _navigateToEditProfile(); // Navigate to Edit Profile
                } else {
                  Utils.showError(context, "User not found. Please log in again.");
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),

            Divider(thickness: 1, color: Colors.grey),

            // Delete Profile
            GestureDetector(
              onTap: _showDeleteAccountDialog,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Delete Profile",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Log Out
            GestureDetector(
              onTap: _logout,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Log Out",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

