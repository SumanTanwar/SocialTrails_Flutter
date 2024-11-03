import 'package:firebase_database/firebase_database.dart';
import 'package:socialtrailsapp/Interface/IFollowService.dart';
import '../ModelData/UserFollow.dart';
import 'UserService.dart';


class FollowService implements IFollowService {
  final DatabaseReference reference;
  static const String _collectionName = "userfollow";
  final UserService userService;

  FollowService()
      : reference = FirebaseDatabase.instance.ref(),
        userService = UserService();

  @override
  Future<List<String>> getFollowAndFollowerIdsByUserId(String userId) async {
    Set<String> allIds = {};
    try {
      DatabaseEvent event = await reference.child(_collectionName)
          .orderByChild("userId")
          .equalTo(userId)
          .once();

      if (event.snapshot.exists) {
        for (DataSnapshot ds in event.snapshot.children) {
          // Use a dynamic cast to avoid type issues
          final dynamic value = ds.value;

          if (value is Map) {
            UserFollow userFollow = UserFollow.fromJson(Map<String, dynamic>.from(value));

            userFollow.followingIds.forEach((id, isFollowing) {
              if (isFollowing) {
                allIds.add(id);
                print("Following ID: $id");
              }
            });
           // allIds.addAll(userFollow.followerIds);
          } else {
            print("Unexpected data format for user follow: $value");
          }
        }
      } else {
        print("No data found for user: $userId");
      }

      return allIds.toList();
    } catch (error) {
      print("Error fetching follow and follower IDs: $error");
      throw Exception("Error fetching follow and follower IDs: $error");
    }
  }

  Future<void> sendFollowRequest(String currentUserId, String userIdToFollow) async {
    try {
      final DatabaseReference followRef = reference.child(_collectionName);
      final snapshot = await followRef.orderByChild("userId").equalTo(currentUserId).once();

      if (snapshot.snapshot.value != null) {
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String followKey = userFollowMap.keys.first;

        final userFollow = userFollowMap[followKey] as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null) {
          followingIds[userIdToFollow] = true;
          userFollow["followingIds"] = followingIds;

          await followRef.child(followKey).update(Map<String, dynamic>.from(userFollow));
          print("Follow request sent successfully.");
        }
      } else {
        final String followId = followRef.push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
        final newUserFollow = {
          "followId": followId,
          "userId": currentUserId,
          "followingIds": {userIdToFollow: true},
          "followerIds": [],
          "createdOn": DateTime.now().toIso8601String(),
        };

        await followRef.child(followId).set(newUserFollow);
        print("Follow request created successfully.");
      }
    } catch (error) {
      print("Error sending follow request: $error");
      throw Exception("Error sending follow request: $error");
    }
  }

  Future<bool> checkPendingRequestsForCancel(String currentUserId, String userIdToCheck) async {
    try {
      final snapshot = await reference.child(_collectionName).orderByChild("userId").equalTo(currentUserId).once();

      if (snapshot.snapshot.value == null) {
        throw Exception("User not found");
      }

      final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
      for (var value in userFollowMap.values) {
        final userFollow = value as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null && followingIds[userIdToCheck] == false) {
          return true; // Pending request exists
        }
      }

      return false; // No pending requests
    } catch (error) {
      throw Exception("Error checking pending requests: $error");
    }
  }

  Future<void> cancelFollowRequest(String currentUserId, String userIdToUnfollow) async {
    try {
      final snapshot = await reference.child(_collectionName).orderByChild("userId").equalTo(currentUserId).once();

      if (snapshot.snapshot.value == null) {
        throw Exception("User not found");
      }

      final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
      for (var key in userFollowMap.keys) {
        final userFollow = userFollowMap[key] as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null && followingIds.containsKey(userIdToUnfollow)) {
          followingIds.remove(userIdToUnfollow);
          userFollow["followingIds"] = followingIds;

          await reference.child(key).update(Map<String, dynamic>.from(userFollow));
          print("Follow request cancelled successfully.");
          return;
        }
      }

      throw Exception("No follow request found to cancel.");
    } catch (error) {
      throw Exception("Error cancelling follow request: $error");
    }
  }

  Future<void> confirmFollowRequest(String currentUserId, String userIdToFollow) async {
    try {
      final snapshot = await reference.child(_collectionName).orderByChild("userId").equalTo(userIdToFollow).once();

      if (snapshot.snapshot.value == null) {
        throw Exception("Follow request not found.");
      }

      final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
      for (var key in userFollowMap.keys) {
        final userFollow = userFollowMap[key] as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null) {
          followingIds[currentUserId] = true; // Add current user to following IDs
          userFollow["followingIds"] = followingIds;

          await reference.child(key).update(Map<String, dynamic>.from(userFollow));
          print("Follow request confirmed successfully.");
          return;
        }
      }

      throw Exception("Follow request not found.");
    } catch (error) {
      throw Exception("Error confirming follow request: $error");
    }
  }

  Future<void> rejectFollowRequest(String currentUserId, String userIdToFollow) async {
    try {
      final snapshot = await reference.child(_collectionName)
          .orderByChild("userId")
          .equalTo(userIdToFollow)
          .once();

      if (snapshot.snapshot.value != null) {
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;

        for (var key in userFollowMap.keys) {
          final userFollow = userFollowMap[key] as Map<dynamic, dynamic>;
          final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

          if (followingIds != null) {
            followingIds.remove(currentUserId);
            userFollow["followingIds"] = followingIds;

            await reference.child(key).update(Map<String, dynamic>.from(userFollow));
            print("Follow request rejected successfully.");
            return; // Exit after updating
          }
        }
        throw Exception("Follow request not found.");
      } else {
        throw Exception("Follow request not found.");
      }
    } catch (error) {
      print("Error rejecting follow request: $error");
      throw Exception("Error rejecting follow request: $error");
    }
  }
  Future<void> confirmFollowBack(String currentUserId, String userIdToFollow) async {
    try {
      final snapshot = await reference.child(_collectionName)
          .orderByChild("userId")
          .equalTo(currentUserId)
          .once();

      if (snapshot.snapshot.value != null) {
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;

        for (var key in userFollowMap.keys) {
          final userFollow = userFollowMap[key] as Map<dynamic, dynamic>;
          final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

          if (followingIds != null) {
            followingIds[userIdToFollow] = true; // Add userIdToFollow to following IDs
            userFollow["followingIds"] = followingIds;

            await reference.child(key).update(Map<String, dynamic>.from(userFollow));
            print("Follow back confirmed successfully.");
            return; // Exit after updating
          }
        }
      } else {
        // Create a new UserFollow entry if none exists
        final followId = reference.child(_collectionName).push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
        final newUserFollow = {
          "userId": currentUserId,
          "followingIds": {userIdToFollow: true},
          "followerIds": [],
        };

        await reference.child(_collectionName).child(followId).set(newUserFollow);
        print("Follow back confirmed with new entry.");
      }
    } catch (error) {
      print("Error confirming follow back: $error");
      throw Exception("Error confirming follow back: $error");
    }
  }


}
