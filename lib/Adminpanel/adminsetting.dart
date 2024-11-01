import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialtrailsapp/Adminpanel/adminchangepassword.dart';
import 'package:socialtrailsapp/Adminpanel/createmoderator.dart';
import 'package:socialtrailsapp/ModelData/UserRole.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/signin.dart';

class AdminSettingsScreen extends StatefulWidget {
  @override
  _AdminSettingsScreenState createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userRole = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSessionManager();
    userRole = SessionManager()!.getRoleType() ?? UserRole.admin.role;// Ensure SessionManager is initialized
  }

  Future<void> _initializeSessionManager() async {
    await SessionManager().init(); // Ensure initialization
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    String? userId = SessionManager().getUserID();
    UserService userService = UserService();

    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        final data = await userService.getUserByID(userId!);
        setState(() {
         // Use null-aware operator
          isLoading = false;
        });
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        // Handle error (e.g., show a snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user role: $error')),
        );
      }
    } else {
      // User not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SigninScreen()),
      );
    }
  }

  void _logout() {
    SessionManager().logoutUser(); // Ensure to logout from session manager
    _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userRole == 'moderator' ? 'MODERATOR' : 'ADMIN'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/socialtrails_logo.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 10),
                  Text(
                    userRole == 'moderator' ? 'Moderator' : 'Admin',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              userRole == 'moderator' ? 'Moderator Settings' : 'Admin Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Only show "Create Moderator" for admin
            if (userRole != 'moderator') ...[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => AdminCreateModeratorPage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    "Create Moderator",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
              Divider(thickness: 1, color: Colors.grey),
            ],

            // Change Password option is available to both roles
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => AdminChangePasswordScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Change Password",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Log Out option is available to both roles
            GestureDetector(
              onTap: _logout,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
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