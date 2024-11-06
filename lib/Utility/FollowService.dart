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
        // Existing user found
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String followKey = userFollowMap.keys.first;

        final userFollow = userFollowMap[followKey] as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null) {
          // If `followingIds` is null, initialize it
          followingIds[userIdToFollow] = false;  // Set to false or true depending on your logic

          // Update the `followingIds` in the database
          userFollow["followingIds"] = followingIds;
          await followRef.child(followKey).update(Map<String, dynamic>.from(userFollow));
          print("Follow request sent successfully.");
        } else {
          // If `followingIds` doesn't exist, initialize it with the new user
          userFollow["followingIds"] = {userIdToFollow: false};  // Set initial follow status to false
          await followRef.child(followKey).update(Map<String, dynamic>.from(userFollow));
          print("Follow request sent successfully, followingIds initialized.");
        }
      } else {
        // No existing user found, create a new follow entry
        final String followId = followRef.push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
        final newUserFollow = {
          "followId": followId,
          "userId": currentUserId,
          "followingIds": {userIdToFollow: false},  // Initialize followingIds with the user being followed
          "followerIds": [],  // Empty initially, depending on your app's requirements
          "createdOn": DateTime.now().toIso8601String(),
        };

        await followRef.child(followId).set(newUserFollow);
        print("New follow request created successfully.");
      }
    } catch (error) {
      print("Error sending follow request: $error");
      throw Exception("Error sending follow request: $error");
    }
  }

  Future<bool> checkPendingRequestsForCancel(String currentUserId, String userIdToFollow) async {
    try {
      final snapshot = await reference.child(_collectionName).orderByChild("userId").equalTo(currentUserId).once();

      if (snapshot.snapshot.value == null) {
        throw Exception("User not found");
      }

      final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
      for (var value in userFollowMap.values) {
        final userFollow = value as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null && followingIds[userIdToFollow] == false) {
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

      // Log the snapshot to verify if data is fetched correctly
      print("Snapshot data: ${snapshot.snapshot.value}");

      if (snapshot.snapshot.value == null) {
        throw Exception("User not found in the follow collection.");
      }

      final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;

      for (var key in userFollowMap.keys) {
        final userFollow = UserFollow.fromJson(Map<String, dynamic>.from(userFollowMap[key]));

        // Log the userFollow to check its contents
        print("UserFollow object: $userFollow");

        if (userFollow.followingIds.containsKey(userIdToUnfollow)) {
          // Remove the user from followingIds
          userFollow.followingIds.remove(userIdToUnfollow);

          // Log the updated followingIds
          print("Updated followingIds: ${userFollow.followingIds}");

          // Set the data in Firebase
          await reference.child(_collectionName).child(key).set({
            'followId': userFollow.followId,
            'userId': userFollow.userId,
            'followerIds': userFollow.followerIds,
            'followingIds': userFollow.followingIds.isEmpty ? null : userFollow.followingIds,  // Set to null if empty
            'createdOn': userFollow.createdOn,
          });

          print("Follow request canceled successfully.");
          return;
        }
      }

      throw Exception("Follow request not found for cancellation.");
    } catch (error) {
      print("Error cancelling follow request: $error");
      throw Exception("Error cancelling follow request: $error");
    }
  }



  Future<bool> checkPendingForFollowingUser(String currentUserId, String userIdToCheck) async {
    try {
      final snapshot = await reference
          .child(_collectionName)
          .orderByChild("userId")
          .equalTo(userIdToCheck)
          .once();

      if (snapshot.snapshot.value != null) {
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final followKey = userFollowMap.keys.first;

        final userFollow = userFollowMap[followKey] as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        // Check if the userToCheck is present in followingIds and has a 'false' value (indicating a pending follow)
        if (followingIds != null && followingIds.containsKey(currentUserId) && followingIds[currentUserId] == false) {
          return true;  // There's a pending follow request
        }
      }

      return false;  // No pending follow request
    } catch (error) {
      print("Error checking pending follow request: $error");
      return false;  // If there's an error, assume no pending request
    }
  }

////////////confirm

  Future<void> confirmFollowRequest(String currentUserId, String userIdToFollow) async {
    try {
      // Query for the user to follow
      final snapshot = await reference
          .child(_collectionName)
          .orderByChild('userId')
          .equalTo(userIdToFollow)
          .once();

      if (snapshot.snapshot.value != null) {
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final userFollowKey = userFollowMap.keys.first;
        final userFollow = userFollowMap[userFollowKey] as Map<dynamic, dynamic>;

        final followingIds = userFollow['followingIds'] as Map<dynamic, dynamic>?;

        if (followingIds != null) {
          final updatedFollowingIds = Map<String, bool>.from(followingIds);
          updatedFollowingIds[currentUserId] = true;

          // Corrected line with string interpolation
          await reference.child('$_collectionName/$userFollowKey').update({
            'followingIds': updatedFollowingIds,
          });

          // Use named parameters when calling addFollowers
          await addFollowers(
            currentUserId: userIdToFollow,
            userIdToFollow: currentUserId,
          );

          print('Follow request confirmed');
        }
      } else {
        throw Exception("Follow request not found.");
      }
    } catch (error) {
      print("Error confirming follow request: $error");
      throw error;
    }
  }

  Future<void> addFollowers({
    required String currentUserId,
    required String userIdToFollow,
  }) async {
    try {
      final snapshot = await reference
          .child(_collectionName)
          .orderByChild('userId')
          .equalTo(userIdToFollow)
          .once();

      if (snapshot.snapshot.exists) {
        final userFollowData = snapshot.snapshot.children.first;

        if (userFollowData.value is Map) {
          Map<String, dynamic> userFollow = Map<String, dynamic>.from(userFollowData.value as Map);
          List<String> followerIds = List<String>.from(userFollow['followerIds'] ?? []);

          // Check if the current user is already a follower
          if (!followerIds.contains(currentUserId)) {
            followerIds.add(currentUserId);
            userFollow['followerIds'] = followerIds;

            // Update the database
            await reference.child('$_collectionName/${userFollowData.key!}').update(userFollow as Map<String, Object?>);
            print('Followed successfully.');
          } else {
            print('Already a follower.');
          }
        } else {
          print('Unexpected data format: ${userFollowData.value}');
        }
      } else {
        // Fix: Ensure this follow relationship is placed within the correct collection
        String followId = reference.child(_collectionName).push().key ?? DateTime.now().toIso8601String();
        Map<String, dynamic> newUserFollow = {
          'followId': followId,
          'userId': userIdToFollow,
          'followingIds': [],
          'followerIds': [currentUserId],
          'createdOn': DateTime.now().toIso8601String(),
        };

        // Ensure that this new follow is added to the correct collection
        await reference.child('$_collectionName/$followId').set(newUserFollow);
        print('Follow relationship created.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  ///////// reject

  Future<void> rejectFollowRequest({
    required String currentUserId,
    required String userIdToFollow,
  }) async {
    try {
      DatabaseReference userRef = reference.child(_collectionName);

      final snapshot = await userRef
          .orderByChild('userId')
          .equalTo(userIdToFollow)
          .once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;

        for (var key in userFollowMap.keys) {
          var userFollow = userFollowMap[key];

          if (userFollow != null && userFollow['followingIds'] != null) {
            Map<dynamic, dynamic> followingIds = Map.from(userFollow['followingIds']);

            followingIds.remove(currentUserId);

            await userRef.child(key).update({'followingIds': followingIds});

            return;
          }
        }

        throw Exception('Follow request not found.');
      } else {
        throw Exception('Follow request not found.');
      }
    } catch (e) {
      throw Exception('Error rejecting follow request: $e');
    }
  }

///////checkiffollowed

  Future<bool> checkIfFollowed(String currentUserId, String userIdToCheck) async {
    try {
      // Query the database to find the user record associated with currentUserId
      final followRef = reference.child(_collectionName);
      final snapshot = await followRef.orderByChild("userId").equalTo(userIdToCheck).once();

      if (snapshot.snapshot.value != null) {
        // Extract the user data from the snapshot
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String followKey = userFollowMap.keys.first;

        final userFollow = userFollowMap[followKey] as Map<dynamic, dynamic>;
        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        // Check if the userIdToCheck exists in followingIds
        if (followingIds != null && followingIds.containsKey(currentUserId) && followingIds[currentUserId] == true) {
          // User is following the userIdToCheck
          return true;
        }
      }

      // Return false if no such user is found or the user is not following
      return false;
    } catch (error) {
      print("Error checking follow status: $error");
      throw Exception("Error checking follow status: $error");
    }
  }

  Future<void> unfollowUser({
    required String currentUserId,
    required String userIdToUnfollow,
  }) async {
    try {
      final followRef = reference.child(_collectionName);

      final snapshot = await followRef.orderByChild("userId").equalTo(currentUserId).once();

      if (snapshot.snapshot.value != null) {
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final followKey = userFollowMap.keys.first;
        final userFollow = Map<String, dynamic>.from(userFollowMap[followKey]);

        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null && followingIds.containsKey(userIdToUnfollow)) {
          followingIds.remove(userIdToUnfollow);

          userFollow["followingIds"] = followingIds;
          await followRef.child(followKey).update(Map<String, dynamic>.from(userFollow));
          print("Unfollowed the user successfully.");

          final unfollowedUserRef = followRef.orderByChild("userId").equalTo(userIdToUnfollow);
          final unfollowedSnapshot = await unfollowedUserRef.once();

          if (unfollowedSnapshot.snapshot.value != null) {
            final unfollowedUserMap = unfollowedSnapshot.snapshot.value as Map<dynamic, dynamic>;
            final unfollowedUserKey = unfollowedUserMap.keys.first;
            final unfollowedUser = Map<String, dynamic>.from(unfollowedUserMap[unfollowedUserKey]);

            final followerIds = unfollowedUser["followerIds"] as List<dynamic>?;

            if (followerIds != null && followerIds.contains(currentUserId)) {
              followerIds.remove(currentUserId);

              unfollowedUser["followerIds"] = followerIds;
              await followRef.child(unfollowedUserKey).update(Map<String, dynamic>.from(unfollowedUser));
              print("Unfollowed user’s follower list updated.");
            } else {
              print("Current user is not in the follower list of the unfollowed user.");
            }
          } else {
            throw Exception("User to unfollow not found in followers list.");
          }
        } else {
          throw Exception("User is not in the following list.");
        }
      } else {
        throw Exception("Current user follow entry not found.");
      }
    } catch (error) {
      print("Error while unfollowing user: $error");
      throw Exception("Error while unfollowing user: $error");
    }
  }




  Future<void> confirmFollowBack({
    required String currentUserId,
    required String userIdToFollow,
  }) async {
    try {
      final followRef = reference.child(_collectionName);
      final snapshot = await followRef.orderByChild("userId").equalTo(currentUserId).once();

      if (snapshot.snapshot.value != null) {
        final userFollowMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final String followKey = userFollowMap.keys.first;
        final Map<String, dynamic> userFollow = Map<String, dynamic>.from(userFollowMap[followKey]);

        final followingIds = userFollow["followingIds"] as Map<dynamic, dynamic>?;

        if (followingIds != null) {
          followingIds[userIdToFollow] = true;

          await followRef.child(followKey).update(Map<String, dynamic>.from(userFollow));
          await addFollowers(currentUserId: currentUserId, userIdToFollow: userIdToFollow);
        } else {
          userFollow["followingIds"] = {userIdToFollow: true};

          await followRef.child(followKey).update(Map<String, dynamic>.from(userFollow));
          await addFollowers(currentUserId: currentUserId, userIdToFollow: userIdToFollow);
        }
      } else {
        final followId = followRef.push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
        final newUserFollow = {
          "followId": followId,
          "userId": currentUserId,
          "followingIds": {userIdToFollow: true},
          "followerIds": [],
          "createdOn": DateTime.now().toIso8601String(),
        };

        await followRef.child(followId).set(newUserFollow);
        await addFollowers(currentUserId: currentUserId, userIdToFollow: userIdToFollow);
      }
    } catch (error) {
      throw Exception("Error confirming follow back: $error");
    }
  }


}
