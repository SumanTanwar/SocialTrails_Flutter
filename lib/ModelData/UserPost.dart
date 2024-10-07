import '../Utility/Utils.dart';

class UserPost {
  String? postId;
  String userId;
  String captiontext;
  String? createdon;
  String? updatedon;
  bool postdeleted;
  bool? flagged;
  bool? moderationStatus;
  List<Uri> imageUris;
  double? latitude;
  double? longitude;
  String? location;

  UserPost({
    this.postId,
    required this.userId,
    required this.captiontext,
    required this.imageUris,
    required this.location,
    required this.longitude,
    required this.latitude,
  })  : createdon = Utils.getCurrentDatetime(),
        postdeleted = false;

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'captiontext': captiontext,
      'createdon': createdon,
      'postdeleted': postdeleted,
      'location': location,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}