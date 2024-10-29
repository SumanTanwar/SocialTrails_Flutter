import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'ModelData/UserPost.dart';
import 'Utility/Utils.dart';

class PostItem extends StatelessWidget {
  final UserPost post;

  const PostItem({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: (post.userprofilepicture != null && post.userprofilepicture!.isNotEmpty)
                    ? NetworkImage(post.userprofilepicture!)
                    : AssetImage('assets/user.png') as ImageProvider,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.username ?? 'User Name',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    post.location ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (SessionManager().getUserID() == post.userId)
              Container(
                width: 30,
                height: 30,
                child: IconButton(
                  icon:  Image.asset('assets/menu-dots.png'),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: PageView.builder(
            itemCount: post.uploadedImageUris.length,
            itemBuilder: (context, imageIndex) {
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(post.uploadedImageUris[imageIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Text(
          post.captiontext,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              child: IconButton(
                icon: Image.asset('assets/like.png'),
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(width: 4),
            Text(post.likecount.toString(), style: TextStyle(fontSize: 14)),
            SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              child: IconButton(
                icon: Image.asset('assets/chat.png'),
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(width: 4),
            Text(post.commentcount.toString(), style: TextStyle(fontSize: 14)),
            Spacer(),
            if (SessionManager().getUserID() != post.userId)
              Container(
                width: 30,
                height: 30,
                child: IconButton(
                  icon: Icon(Icons.warning),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        Text(
          Utils.getRelativeTime(post.createdon),
          style: TextStyle(fontSize: 13),
        ),
        Divider(),
      ],
    );
  }
}
