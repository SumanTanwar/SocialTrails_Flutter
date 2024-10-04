import '../Utility/Utils.dart';

class UserPost {
  String? postId;
  String userId;
  String captionText;
  String? createdOn;
  String? updatedOn;
  bool postDeleted;
  bool? flagged;
  bool? moderationStatus;
  List<Uri> imageUris;


  UserPost({
    this.postId,
    required this.userId,
    required this.captionText,
    required this.imageUris,
  })  : createdOn = Utils.getCurrentDatetime(),
        postDeleted = false;

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'captionText': captionText,
      'createdOn': createdOn,
      'postDeleted': postDeleted
    };
  }
}