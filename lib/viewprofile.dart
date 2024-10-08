import 'package:flutter/material.dart';
import 'Utility/SessionManager.dart';
import 'editprofile.dart';

class ViewProfileScreen extends StatelessWidget {
  final String username;
  final String bio;
  final String email; // Add email parameter
  final int postsCount;
  final int followersCount;
  final int followingsCount;

  ViewProfileScreen({
    required this.username,
    required this.bio,
    required this.email, // Include email
    required this.postsCount,
    required this.followersCount,
    required this.followingsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12.0,50.0,12.0,10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/user.png'), // Replace with your asset
                    ),
                    SizedBox(height: 5),
                    Text(
                      username,
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
              bio.isNotEmpty ? bio : 'No bio available',
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
            SizedBox(height: 10),

            Container(
              width: double.infinity,
              child:  ElevatedButton(
                onPressed: () async {

                  String? username = SessionManager().getUsername();
                  String? email = SessionManager().getEmail();
                  String? bio = SessionManager().getBio();


                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        name: username ?? 'Guest',
                        email: email ?? 'No email provided',
                        bio: bio ?? 'No bio available',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text('Edit Profile',style: TextStyle(color: Colors.white)),
              ),
            ),



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
