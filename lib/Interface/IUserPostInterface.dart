import '../ModelData/UserPost.dart';
import 'OperationCallback.dart';

abstract class  IUserPostInterface {
void createPost(UserPost userPost, OperationCallback callback);
}