import '../Utility/Utils.dart';

class PostLike {
  String? postlikeId;
  String postId;
  String userId;
  String createdon;
  String? username;
  String? profilepicture;

  PostLike({
    this.postlikeId,
    required this.postId,
    required this.userId,
    String? createdon,
    this.username,
    this.profilepicture,
  }) : this.createdon = createdon ?? Utils.getCurrentDatetime();

  factory PostLike.fromJson(Map<String, dynamic> json) {
    return PostLike(
      postlikeId: json['postlikeId'],
      postId: json['postId'],
      userId: json['userId'],
      createdon: json['createdon'],
      username: json['username'],
      profilepicture: json['profilepicture'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'postlikeId': postlikeId,
      'postId': postId,
      'userId': userId,
      'createdon': createdon,

    };
  }
}
