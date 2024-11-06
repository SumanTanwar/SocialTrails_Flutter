import 'package:flutter/material.dart';
import 'package:socialtrailsapp/FollowersList.dart';
import 'package:socialtrailsapp/FollowingsList.dart';
import 'package:socialtrailsapp/userpostdetail.dart';
import 'Interface/DataOperationCallback.dart';
import 'ModelData/PostImageData.dart';
import 'ModelData/UserPost.dart';
import 'Utility/SessionManager.dart';
import 'Utility/UserPostService.dart';
import 'package:socialtrailsapp/Utility/FollowService.dart';
import 'editprofile.dart';


class ViewProfileScreen extends StatefulWidget {
  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  List<PostImageData> _postImages = [];
  String currentUserId = SessionManager().getUserID() ?? "";
  int postsCount = 0;
  int followersCount = 0;
  int followingsCount = 0;


  @override
  void initState() {
    super.initState();

    _fetchUserPosts();
    _fetchFollowersCount();
    _fetchFollowingsCount();
  }

  Future<void> _fetchUserPosts() async {
    String userId = SessionManager().getUserID() ?? '';
    UserPostService userPostService = UserPostService();

    await userPostService.getAllUserPost(
        userId, DataOperationCallback<List<UserPost>>(
      onSuccess: (posts) {
        setState(() {
          _postImages = posts
              .where((post) => post.uploadedImageUris?.isNotEmpty == true)
              .map((post) =>
              PostImageData(
                postId: post.postId ?? '',
                imageUrl: post.uploadedImageUris![0],
              ))
              .toList();
          postsCount = _postImages.length;
        });
      },
      onFailure: (error) {
        print("Failed to fetch posts: $error");
      },
    ));
  }


  Future<void> _fetchFollowersCount() async {
    String userId = SessionManager().getUserID() ?? '';
    FollowService followService = FollowService();

    await followService.getFollowersCount(
        userId,
            (count, errorMessage) {
          if (errorMessage == null) {
            setState(() {
              followersCount = count;
            });
          } else {
            print("Error fetching followers count: $errorMessage");
          }
        }
    );
  }

  // Fetch followings count
  Future<void> _fetchFollowingsCount() async {
    String userId = SessionManager().getUserID() ?? '';
    FollowService followService = FollowService();

    await followService.getFollowingsCount(
        userId,
            (count, errorMessage) {
          if (errorMessage == null) {
            setState(() {
              followingsCount = count;
            });
          } else {
            print("Error fetching followings count: $errorMessage");
          }
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    String? imageUrl = SessionManager().getImageUrl();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 50.0, 12.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : AssetImage('assets/user.png') as ImageProvider,
                    ),
                    SizedBox(height: 5),
                    Text(
                      SessionManager().getUsername() ?? 'Unknown User',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(width: 15),
                ProfileStat(
                  count: postsCount.toString(), label: 'Posts', onTap: () {},),
                // Updated to show actual post count
                SizedBox(width: 15),
                ProfileStat(
                  count: followersCount.toString(),
                  label: 'Followers',
                  onTap: () {
                    // Navigate to FollowersList when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          FollowersList(userId: currentUserId,)),
                    );
                  },
                ),
                SizedBox(width: 15),
                ProfileStat(
                  count: followingsCount.toString(),
                  label: 'Followings',
                  onTap: () {
                    // Navigate to FollowingsList when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          FollowingsList(userId: currentUserId)),
                    );
                  },
                ),


              ],
            ),
            SizedBox(height: 10),
            Text(
              SessionManager().getBio() ?? '',
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfileScreen(currentIndex: 4, onTap: (index) {}),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text(
                    'Edit Profile', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),

            _postImages.isNotEmpty
                ? Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                ),
                itemCount: _postImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserPostDetailScreen(
                                  postDetailId: _postImages[index].postId),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        image: DecorationImage(
                          image: NetworkImage(_postImages[index].imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}


  class ProfileStat extends StatelessWidget {
  final String count;
  final String label;
  final VoidCallback onTap;

  ProfileStat({required this.count, required this.label,required this.onTap,});

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
  onTap: onTap, // Attach the onTap callback to GestureDetector
  child: Column(
  children: [
  Text(
  count,
  style: TextStyle(fontSize: 16),
  ),
  Text(
  label,
  style: TextStyle(fontSize: 16),
  ),
  ],
  ),
  );
  }
  }
