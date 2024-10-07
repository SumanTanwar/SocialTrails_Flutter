import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/signin.dart';

import 'adminuserlist.dart';
import 'adminusermanage.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Retrieve admin details
                String username = "Admin";
                String? email = SessionManager().getEmail();

                // Show a message with admin details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Admin: $username, Email: $email')),
                );
              },
              child: Text('Show Admin Details'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminUserDetailManageScreen(userId : "gZbKw6pfnCOrcYTG6kjUbd5nveA2")),
                );
              },
              child: Text('User Detail  Page'),
            ),
            ElevatedButton(
              onPressed: () {
                // Log out admin
                SessionManager().logoutUser();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminUserListScreen()),
                );
              },
              child: Text('User list'),
            ),
            ElevatedButton(
              onPressed: () {
                // Log out admin
                SessionManager().logoutUser();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SigninScreen()),
                );
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
