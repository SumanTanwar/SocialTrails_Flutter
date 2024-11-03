import '../ModelData/UserPost.dart';
import 'DataOperationCallback.dart';
import 'OperationCallback.dart';

abstract class  IUserPostInterface {
  Future<void> createPost(UserPost userPost, DataOperationCallback<String> callback);
  void getAllUserPost(String userId, DataOperationCallback<List<UserPost>> callback);
  Future<void> getAllUserPostDetail(String userId, DataOperationCallback<List<UserPost>> callback);
  Future<void> retrievePostsForFollowedUsers(String currentUserId, DataOperationCallback<List<UserPost>> callback);
  Future<void> updateLikeCount(String postId, int change, DataOperationCallback<int> callback);
  Future<void> getUserPostDetailById(String postId, DataOperationCallback<UserPost> callback);
  Future<void> deleteAllLikesForPost(String postId, Function() onSuccess, Function(String) onFailure);
  Future<void> deleteUserPost(String postId, OperationCallback callback);
  Future<void> getPostByPostId(String postId, DataOperationCallback<UserPost> callback);
}