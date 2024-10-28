import 'package:firebase_database/firebase_database.dart';

import '../Interface/IPostLike.dart';
import 'UserPostService.dart';
import 'UserService.dart';

class PostLikeService  implements IPostLike {
  final DatabaseReference reference;
  static const String _collectionName = "postlike";
  final UserPostService userPostService;
  final UserService userService;

  PostLikeService()
      : reference = FirebaseDatabase.instance.ref(),
        userPostService = UserPostService(),
        userService = UserService();

}