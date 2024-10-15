import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Adminpanel/createmoderator.dart';
import '../ModelData/Users.dart';
import '../Utility/UserService.dart';
import '../Interface/OperationCallback.dart';

class AdminModeratorListScreen extends StatefulWidget {
  @override
  _AdminModeratorListScreenState createState() => _AdminModeratorListScreenState();
}

class _AdminModeratorListScreenState extends State<AdminModeratorListScreen> {
  final UserService userService = UserService();
  List<Users> moderatorsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("AdminModeratorListScreen initialized");
    loadModeratorList();
  }

  void loadModeratorList() async {
    setState(() {
      isLoading = true;
    });
    try {
      moderatorsList = await userService.getModeratorList();
      if (moderatorsList == null || moderatorsList.isEmpty) {
        print("No moderators found.");
      } else {
        print("Moderators data received: $moderatorsList");
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print("Error loading moderators: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteModerator(String userId) {
    userService.deleteUserProfile(
      userId,
      OperationCallback(
        onSuccess: () {
          print("Moderator deleted successfully");
          loadModeratorList();
        },
        onFailure: (error) {
          print("Failed to delete moderator: $error");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building AdminModeratorListScreen with ${moderatorsList.length} moderators");

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(""),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Moderators",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminCreateModeratorPage()),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, size: 30),
                      SizedBox(width: 8),
                      Text(
                        "Create Moderator",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                    ],
                  ),
                ),
              ],
            ),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : moderatorsList.isEmpty
                  ? Center(child: Text("No moderators found."))
                  : ListView.builder(
                itemCount: moderatorsList.length,
                itemBuilder: (context, index) {
                  final moderator = moderatorsList[index];

                  return ListTile(
                    leading: ClipOval(
                      child: Image.network(
                        moderator.profilepicture ,
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/user.png', width: 35, height: 35, fit: BoxFit.cover);
                        },
                      ),
                    ),
                    title: Text(moderator.username),
                    subtitle: Text(moderator.email),

                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteModerator(moderator.userId);
                      },
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
