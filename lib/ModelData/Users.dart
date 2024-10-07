import 'package:firebase_database/firebase_database.dart';

import '../Utility/Utils.dart';


class Users {
  String userId;
  String username;
  String email;
  String? bio;
  String createdon;
  String profilepicture;
  String roles;
  bool profiledeleted;
  bool notification;
  bool admindeleted;
  bool suspended;
  bool isactive;
  String? suspendedreason,suspendedby,admindeletedon;

  Users({
    required this.userId,
    required this.username,
    required this.email,
    required this.roles,
    String? createdon,
    String? bio,
    this.profilepicture = '',
    this.profiledeleted = false,
    this.notification = true,
    this.admindeleted = false,
    this.suspended = false,
    this.isactive = true,
    this.suspendedreason,
    this.admindeletedon,
  }) : createdon = createdon ?? Utils.getCurrentDatetime();

  // Convert a Users object into a Map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'createdon': createdon,
      'bio': bio,
      'profilepicture': profilepicture,
      'roles': roles,
      'profiledeleted': profiledeleted,
      'notification': notification,
      'admindeleted': admindeleted,
      'suspended': suspended,
      'isactive': isactive,
    };
  }

  // Optional: Create a Users object from a Map
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      roles: json['roles'],
      createdon: json['createdon'],
      profilepicture: json['profilepicture'],
      profiledeleted: json['profiledeleted'],
      notification: json['notification'],
      admindeleted: json['admindeleted'],
      suspended: json['suspended'],
      isactive: json['isactive'],
      suspendedreason: json['suspendedreason'],
      admindeletedon: json['admindeletedon'],
    );
  }

  factory Users.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return Users(
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      roles: data['roles'] ?? '',
      createdon: data['createdon'] ?? Utils.getCurrentDatetime(),
      profilepicture: data['profilepicture'] ?? '',
      admindeleted: data['admindeleted'] ?? false,
      profiledeleted: data['profiledeleted'] ?? false,
      suspended: data['suspended'] ?? false,
      suspendedreason: data['suspendedreason'] ?? '',
      admindeletedon: data['admindeletedon'] ?? Utils.getCurrentDatetime(),

    );
  }
}
