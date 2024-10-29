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


}
