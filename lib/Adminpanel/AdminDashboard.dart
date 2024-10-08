import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/signin.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    String username = "Admin";
    String? email = SessionManager().getEmail();
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Admin Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Admin: $username',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Email: ${email ?? "No email available"}',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(onPressed: (){
              SessionManager().logoutUser();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SigninScreen()),
              );
            }, child: Text('logout'))
          ],
        ),
      ),
    );
  }
}
