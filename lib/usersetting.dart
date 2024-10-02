import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/signin.dart';
import 'Utility/Utils.dart';
import 'changepassword.dart';
import '../Interface/OperationCallback.dart';

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
    _usernameController = TextEditingController(text: SessionManager().getUsername() ?? "User");
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
      MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: Colors.red))));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: Colors.green))));
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
                  _userService.deleteProfile(userId, OperationCallback(
                    onSuccess: () async {
                      try {
                        // Delete the user from Firebase Auth
                        await user.delete();
                        // Clear credentials and log out
                        Utils.saveCredentials("", false);
                        SessionManager().logoutUser();
                        await _auth.signOut();


                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => SigninScreen()),
                              (Route<dynamic> route) => false,
                        );
                        Utils.showMessage(context,"Account deleted....");

                      } catch (e) {
                        // Handle error during user deletion
                        _showError("An error occurred while deleting your account. Please try again later.");
                      }
                    },
                    onFailure: (errorMessage) {
                      _showError(errorMessage);
                    },
                  ));
                } else {
                  _showError("User not found. Please log in again.");
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
    return Scaffold(
      appBar: AppBar(title: Text("User Settings")),
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
                    backgroundImage: AssetImage('assets/user.png'),
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

                    String? userId = SessionManager().getUserID(); // Nullable String
                    if (userId != null) {
                      _userService.setNotification(userId, value, OperationCallback(
                        onSuccess: () {
                          SessionManager().setNotificationStatus(value);
                          _showSuccess("Notifications turned ${value ? 'ON' : 'OFF'}");
                        },
                        onFailure: (errorMessage) {
                          _showError("Failed to update notification status: $errorMessage");
                          // Revert the switch if the operation fails
                          setState(() {
                            _notificationsEnabled = !value;
                          });
                        },
                      ));
                    } else {
                      _showError("User ID not found. Please log in again.");
                    }
                  },
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey),

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

            GestureDetector(
              onTap: () {
                // Handle Edit Profile
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

            GestureDetector(
              onTap: _showDeleteAccountDialog, // Show delete account dialog
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Delete Profile",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

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
