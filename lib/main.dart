import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socialtrailsapp/AdminPanel/adminuserlist.dart';
import 'package:socialtrailsapp/Adminpanel/adminsetting.dart';
import 'package:socialtrailsapp/ModelData/UserRole.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/createpost.dart';
import 'package:socialtrailsapp/searchuser.dart';
import 'package:socialtrailsapp/splashscreen.dart';
import 'package:socialtrailsapp/userdashboard.dart';
import 'package:socialtrailsapp/usersetting.dart';
import 'package:socialtrailsapp/viewprofile.dart';
import 'AdminPanel/AdminDashboard.dart';
import 'firebase_options.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_sharp),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
    );
  }
}

class AdminBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.error),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warning),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
    );
  }
}

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final String userRole;
  bool isLoggedIn = false;

  final List<Widget> _userScreens = [
    UserDashboardScreen(),
    SearchUserView(),
    CreatePostScreen(),
    ViewProfileScreen(),
    UserSettingsScreen(),
  ];

  final List<Widget> _adminModeratorScreens = [
    AdminDashboardScreen(),
    AdminUserListScreen(),
    AdminDashboardScreen(),
    AdminDashboardScreen(),
    AdminSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    isLoggedIn = SessionManager().isLoggedIn();
    userRole = SessionManager().getRoleType().toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const splashscreen();
    }

    bool isAdminOrModerator = userRole == UserRole.admin.getRole() || userRole == UserRole.moderator.getRole();
  
    List<Widget> screens = isAdminOrModerator ? _adminModeratorScreens : _userScreens;

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: isAdminOrModerator
          ? AdminBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      )
          : BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
