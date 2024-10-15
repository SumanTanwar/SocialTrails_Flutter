import 'package:flutter/material.dart';
import 'Interface/DataOperationCallback.dart';
import 'Utility/SessionManager.dart';
import 'Utility/UserPostService.dart';
import 'editprofile.dart';
import '../ModelData/UserPost.dart';


class ViewProfileScreen extends StatefulWidget {


  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  List<String> _postImages = []; // To store post images
   int postsCount = 0;
   int followersCount = 0;
   int followingsCount = 0;
  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    print("function call");
    String userId = SessionManager().getUserID() ?? ''; // Get the user ID
    UserPostService userPostService = UserPostService();
    print("uuserid : $userId");

    await userPostService.getAllUserPost(userId, DataOperationCallback<List<UserPost>>(
      onSuccess: (posts) {

        //print("posts count : $count");
        setState(() {

          _postImages = posts
              .map((post) => (post.uploadedImageUris?.isNotEmpty == true)
              ? post.uploadedImageUris![0]
              : null)
              .where((image) => image != null)
              .cast<String>()
              .toList();

          postsCount = _postImages.length;
        });
      },
      onFailure: (error) {
        // Handle error
        print("Failed to fetch posts: $error");
      },
    ));
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
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(width: 15),
                _buildStatColumn(postsCount, "Posts"),
                SizedBox(width: 15),
                _buildStatColumn(followersCount, "Followers"),
                SizedBox(width: 15),
                _buildStatColumn(followingsCount, "Followings"),
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
                      builder: (context) => EditProfileScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text('Edit Profile', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
            // Display the gallery of images
            _postImages.isNotEmpty
                ? Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Adjust as needed
                  childAspectRatio: 1,
                // crossAxisSpacing: 1,
                 // mainAxisSpacing: 8,
                ),
                itemCount: _postImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      //borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey, width: 1),
                      image: DecorationImage(
                        image: NetworkImage(_postImages[index].toString()),
                        fit: BoxFit.cover,
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

  Widget _buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }
}
