import '../Utility/Utils.dart';

class NotificationModal {
  String? notificationId;
  String notifyto;
  String type;
  String message;
  String relatedId;
  String createdon;
  String notifyBy;
  String? username;
  String? userProfilePicture;

  NotificationModal({
     this.notificationId,
    required this.notifyto,
    required this.notifyBy,
    required this.type,
    required this.message,
    required this.relatedId,
    String? createdon,
    this.username,
    this.userProfilePicture,
  }) : this.createdon = createdon ?? Utils.getCurrentDatetime();

  // Factory method to create a Notification from JSON
  factory NotificationModal.fromJson(Map<String, dynamic> json) {
    return NotificationModal(
      notificationId: json['notificationId'] as String,
      notifyto: json['notifyto'] as String,
      notifyBy: json['notifyBy'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      relatedId: json['relatedId'] as String,
      createdon: json['createdon'] as String,
      username: json['username'] as String?,
      userProfilePicture: json['userProfilePicture'] as String?,
    );
  }

  // Method to convert a Notification to JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'notifyto': notifyto,
      'notifyBy': notifyBy,
      'type': type,
      'message': message,
      'relatedId': relatedId,
      'createdon': createdon,

    };
  }
}
