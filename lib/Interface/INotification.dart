
import '../ModelData/Notification.dart';
import '../ModelData/Users.dart';

abstract class INotification{
  Future<void> sendNotificationToUser(NotificationModal notification);
  Future<List<NotificationModal>> fetchNotifications(String userId);
  Future<Users?> retrieveUserDetails(String userId);
}