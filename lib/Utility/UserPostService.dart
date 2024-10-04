import 'package:firebase_database/firebase_database.dart';
import '../Interface/IUserPostInterface.dart';
import '../Interface/OperationCallback.dart';
import '../ModelData/UserPost.dart';
import 'PostImagesService.dart';

class UserPostService implements IUserPostInterface {
  final DatabaseReference reference;
  static const String _collectionName = "post";
  final PostImagesService postImagesService;

  UserPostService()
      : reference = FirebaseDatabase.instance.ref(),
        postImagesService = PostImagesService();

  @override
  Future<void> createPost(UserPost userPost, OperationCallback callback) async {
    try {
      String newItemKey = reference.child(_collectionName).push().key!;
      userPost.postId = newItemKey;
      await reference.child(_collectionName).child(newItemKey).set(userPost.toJson());
      await  postImagesService.uploadImages(newItemKey, userPost.imageUris,OperationCallback(onSuccess: (){
        print("Images uploaded successfully.");
        callback.onSuccess();
      }, onFailure:(e){
        print("Images failed successfully. $e");
        callback.onFailure(e.toString());
      }));
      callback.onSuccess();
    } catch (e) {
      callback.onFailure(e.toString());
    }
  }

}
