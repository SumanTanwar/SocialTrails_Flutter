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
            allIds.addAll(userFollow.followerIds);
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
    final DatabaseReference followRef = FirebaseDatabase.instance.ref("userFollows");

    try {
      final snapshot = await followRef.orderByChild("userId").equalTo(currentUserId).once();

      if (snapshot.snapshot.value != null) { // Check if data exists
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String followKey = userFollowMap.keys.first;

        // Update following IDs
        final userFollow = userFollowMap[followKey] as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null) {
          followingIds[userIdToFollow] = true;
          userFollow["followingIds"] = followingIds;

          await followRef.child(followKey).update(Map<String, dynamic>.from(userFollow)); // Cast to the correct type
          print("Follow request sent successfully.");
        }
      } else {
        // Create a new follow entry
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
      print("Error: $error");
    }
  }
  Future<bool> checkPendingRequestsForCancel(String currentUserId, String userIdToCheck) async {
    final DatabaseReference reference = FirebaseDatabase.instance.ref("userFollows");

    try {
      final snapshot = await reference.orderByChild("userId").equalTo(currentUserId).once();

      if (snapshot.snapshot.value == null) {
        throw Exception("User not found");
      }

      bool hasPendingRequest = false;
      final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;

      for (var value in userFollowMap.values) {
        final userFollow = value as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null && followingIds[userIdToCheck] == false) {
          hasPendingRequest = true;
          break;
        }
      }

      return hasPendingRequest;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> cancelFollowRequest(String currentUserId, String userIdToUnfollow) async {
    final DatabaseReference reference = FirebaseDatabase.instance.ref("userFollows");

    try {
      final snapshot = await reference.orderByChild("userId").equalTo(currentUserId).once();

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

          // Ensure the map is of the correct type before updating
          await reference.child(key).update(Map<String, dynamic>.from(userFollow)); // Update the follow request
          return; // Exit after updating
        }
      }

      throw Exception("No follow request found to cancel.");
    } catch (error) {
      throw Exception(error);
    }
  }


}
