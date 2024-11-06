import 'package:firebase_database/firebase_database.dart';

import '../Interface/INotification.dart';
import '../ModelData/Notification.dart';
import '../ModelData/Users.dart';
import 'UserService.dart';

class NotificationService implements INotification {
  final DatabaseReference reference;
  static const String _collectionName = "notifications";
  final UserService userService;

  NotificationService()
      : reference = FirebaseDatabase.instance.ref(),
        userService = UserService();

  @override
  Future<void> sendNotificationToUser(NotificationModal notification) async {
    try {
      final notificationRef = reference.child(_collectionName);
      final notificationId = notificationRef.push().key;
      notification.notificationId = notificationId; // Set the notification ID

      if (notificationId != null) {
        await notificationRef.child(notificationId).set(notification.toJson());
        print("Notification sent successfully.");
      } else {
        print("Failed to generate notification ID.");
      }
    } catch (e) {
      print("Failed to send notification: ${e.toString()}");
    }
  }
  @override
  Future<List<NotificationModal>> fetchNotifications(String userId) async {
    final notificationRef = reference.child(_collectionName);
    final notifications = <NotificationModal>[];

    try {
      final dataSnapshot = await notificationRef
          .orderByChild("notifyto")
          .equalTo(userId)
          .once();

      final totalNotifications = dataSnapshot.snapshot.children.length;

      if (totalNotifications > 0) {
        for (final snapshot in dataSnapshot.snapshot.children) {
          final notification = NotificationModal.fromJson(
              Map<String, dynamic>.from(snapshot.value as Map));

          notifications.add(notification); // Add notification

          // Fetch user details for each notification
          try {
            final userDetails = await retrieveUserDetails(notification.notifyBy);
            notification.username = userDetails?.username ?? "Warning issue by admin : ";
            print("notification name : ${ notification.username }");
            notification.userProfilePicture = userDetails?.profilepicture ?? "";
          } catch (e) {
            print("Failed to fetch user details: ${e.toString()}");
          }
        }

        // Sort notifications by createdOn timestamp
        notifications.sort((n1, n2) => n2.createdon.compareTo(n1.createdon));
      }

      return notifications; // Return the list of notifications
    } catch (e) {
      print("Error fetching notifications: ${e.toString()}");
      throw e; // Rethrow the exception to the caller
    }
  }
  @override
  Future<Users?> retrieveUserDetails(String userId) async {
    try {
      return await userService.getUserByID(userId);
    } catch (e) {
      throw Exception("User not found");
    }
  }
}