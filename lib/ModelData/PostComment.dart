
import '../Utility/Utils.dart';

class PostComment {
  String? postcommentId;
  String postId;
  String userId;
  String commenttext;
  String createdon;
  String? username;
  String? userprofilepicture;

  PostComment({
    this.postcommentId,
    required this.postId,
    required this.userId,
    required this.commenttext,
    String? createdon,
    this.username,
    this.userprofilepicture,
  }) : this.createdon = createdon ?? Utils.getCurrentDatetime();


  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      postcommentId: json['postcommentId'],
      postId: json['postId'],
      userId: json['userId'],
      commenttext: json['commenttext'],
      createdon: json['createdon'],
      username: json['username'],
      userprofilepicture: json['userprofilepicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postcommentId': postcommentId,
      'postId': postId,
      'userId': userId,
      'commenttext': commenttext,
      'createdon': createdon,

    };
  }
}
