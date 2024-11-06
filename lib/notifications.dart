import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/userdashboard.dart';
import '../ModelData/Notification.dart';
import 'Utility/NotificationService.dart';
import 'follounfollow.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModal> notifications = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }
  Future<void> fetchNotifications() async {
    String userId = SessionManager().getUserID() ?? ""; // Replace with your user ID fetching logic
    final notificationService = NotificationService();

    try {
      final fetchedNotifications = await notificationService.fetchNotifications(userId);
      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching notifications: ${error.toString()}");
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: Column(
        children: [
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (notifications.isEmpty)
            Center(child: Text("No notifications available.", style: TextStyle(color: Colors.grey)))
          else
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  NotificationModal notification = notifications[index];
                  return ListTile(
                    leading:   Container(
                      width: 40,
                      height: 40,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: (notification.userProfilePicture != null && notification.userProfilePicture!.isNotEmpty)
                            ? NetworkImage(notification.userProfilePicture!)
                            : AssetImage('assets/user.png') as ImageProvider,
                      ),
                    ),
                    title: Text('${notification.username ??  "Warning issue by admin : "}${notification.message}'),
                    onTap: () {
                      if (notification.type.toLowerCase() == "post") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserDashboardScreen()), // Replace with your actual view
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FollowUnfollowView(userIdToFollow: notification.relatedId)), // Replace with your actual view
                        );
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }


}
