import 'package:flutter/material.dart';
import '../AdminPanel/adminusermanage.dart';
import '../ModelData/Users.dart';
import '../Utility/UserService.dart';
import '../Utility/SessionManager.dart'; // Import SessionManager
import 'adminmoeratorlist.dart';

class AdminUserListScreen extends StatefulWidget {
  @override
  _AdminUserListScreenState createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final UserService userService = UserService();
  List<Users> usersList = [];
  String userRole = ''; // Variable to hold user role
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _initializeSessionManager(); // Initialize session manager
    loadUserList();
  }

  Future<void> _initializeSessionManager() async {
    await SessionManager().init(); // Ensure initialization
    _getUserRole(); // Get user role
  }

  Future<void> _getUserRole() async {
    String? userId = SessionManager().getUserID();
    UserService userService = UserService();

    if (userId != null) {
      try {
        final data = await userService.getUserByID(userId);
        setState(() {
          userRole = data?.roles ?? 'admin'; // Set user role
          isLoading = false; // Update loading state
        });
      } catch (error) {
        setState(() {
          isLoading = false; // Update loading state
        });
        // Handle error (e.g., show a snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user role: $error')),
        );
      }
    } else {
      // Handle case where userId is null
    }
  }

  void loadUserList() {
    userService.getRegularUserList().then((data) {
      setState(() {
        usersList = data;
      });
      print("Users list updated with ${usersList.length} users");
    }).catchError((error) {
      print("Error loading users: $error");
    });
  }

  Color getStatusColor(Users user) {
    if (user.profiledeleted || user.admindeleted) {
      return Colors.red;
    } else if (user.suspended) {
      return Color(0xFFFF9800);
    }
    return Colors.transparent;
  }

  String getStatusText(Users user) {
    if (user.profiledeleted || user.admindeleted) {
      return "Deleted";
    } else if (user.suspended) {
      return "Suspended";
    }
    return ""; // No status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Regular Users",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                // Only show "Moderator" if the user is not a moderator
                if (userRole != 'moderator') ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminModeratorListScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, size: 30),
                        SizedBox(width: 8),
                        Text(
                          "Moderator",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: usersList.isEmpty
                  ? Center(child: Text("No users found."))
                  : ListView.builder(
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  final user = usersList[index];
                  return ListTile(
                    leading: ClipOval(
                      child: Image.network(
                        user.profilepicture,
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/user.png', width: 35, height: 35, fit: BoxFit.cover);
                        },
                      ),
                    ),
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminUserDetailManageScreen(userId: user.userId),
                        ),
                      );
                    },
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: getStatusColor(user),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        getStatusText(user),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
