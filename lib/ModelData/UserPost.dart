import '../Utility/Utils.dart';

class UserPost {
  String? postId;
  String userId;
  String captiontext;
  String? createdon;
  String? updatedon;
  bool postdeleted;
  bool? flagged;
  bool? moderationstatus;
  List<Uri>  imageUris;
  double? latitude;
  double? longitude;
  String? location;
  List<String> uploadedImageUris;
  int likecount;
  bool isliked;
  int commentcount;
  String? username;
  String? userprofilepicture;

  UserPost({
    this.postId,
    required this.userId,
    required this.captiontext,
    required this.imageUris,
    required this.location,
    required this.longitude,
    required this.latitude,
    this.uploadedImageUris = const [],
    this.likecount = 0,
    this.isliked = false,
    this.commentcount = 0,
    this.username,
    this.userprofilepicture,
  })  : createdon = Utils.getCurrentDatetime(),
        postdeleted = false;

  UserPost.withoutImages({
    this.postId,
    required this.userId,
    required this.captiontext,
    required this.location,
    required this.longitude,
    required this.latitude,
    this.uploadedImageUris = const [],
    this.likecount = 0,
    this.isliked = false,
    this.commentcount = 0,
    this.username,
    this.userprofilepicture,
  })  : imageUris = [],
        createdon = Utils.getCurrentDatetime(),
        postdeleted = false;

  factory UserPost.fromJson(Map<String, dynamic> json) {
    return UserPost.withoutImages(
      postId: json['postId'] as String?,
      userId: json['userId'] as String,
      captiontext: json['captiontext'] as String,
      location: json['location'] as String?,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      uploadedImageUris: List<String>.from(json['uploadedImageUris'] ?? []),

    )
      ..createdon = json['createdon'] as String?
      ..postdeleted = json['postdeleted'] as bool? ?? false
      ..likecount = json['likecount'] as int? ?? 0
      ..isliked = json['isliked'] as bool? ?? false
      ..commentcount = json['commentcount'] as int? ?? 0
      ..username = json['username'] as String?
      ..userprofilepicture = json['userprofilepicture'] as String?;
  }

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