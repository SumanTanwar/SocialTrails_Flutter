import 'package:flutter/material.dart';
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
    userService.deleteProfile(
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
      appBar: AppBar(
        title: Text("Moderators"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50),
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
