
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Adminpanel/adminchangepassword.dart';
import 'package:socialtrailsapp/Adminpanel/adminsetting.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/splashscreen.dart';
import 'package:socialtrailsapp/userdashboard.dart';
import 'package:socialtrailsapp/usersetting.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SessionManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Trails App',
      theme: ThemeData(
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SessionManager().isLoggedIn() ?  const UserDashboardScreen() : AdminChangePasswordScreen(),
    );
  }
}
