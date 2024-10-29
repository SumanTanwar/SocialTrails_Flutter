import 'dart:convert';

import '../Utility/Utils.dart';

class UserFollow {
  String followId;
  String userId;
  List<String> followerIds;
  Map<String, bool> followingIds;
  String? createdOn;

  UserFollow({
    required this.followId,
    required this.userId,
    List<String>? followerIds,
    Map<String, bool>? followingIds,
    String? createdOn,

  })  : followerIds = followerIds ?? [],
       this.createdOn = createdOn ?? Utils.getCurrentDatetime(),
        followingIds = followingIds ?? {};

  // Factory constructor to create an instance from JSON
  factory UserFollow.fromJson(Map<String, dynamic> json) {
    return UserFollow(
      followId: json['followId'] ?? '',
      userId: json['userId'] ?? '',
      followingIds: Map<String, bool>.from(json['followingIds'] ?? {}),
      followerIds: List<String>.from(json['followerIds'] ?? []),

    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'followId': followId,
      'userId': userId,
      'followerIds': followerIds,
      'followingIds': followingIds,
      'createdOn': createdOn,
    };
  }
}
