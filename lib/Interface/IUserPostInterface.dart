import '../ModelData/UserPost.dart';
import 'DataOperationCallback.dart';
import 'OperationCallback.dart';

abstract class  IUserPostInterface {
void createPost(UserPost userPost, OperationCallback callback);
void getAllUserPost(String userId, DataOperationCallback<List<UserPost>> callback);
}