import '../ModelData/LikeResult.dart';
import '../ModelData/PostLike.dart';
import 'DataOperationCallback.dart';
import 'OperationCallback.dart';

abstract class IPostLike {
  void likeAndUnlikePost(String postId, String userId, DataOperationCallback<LikeResult> callback);
  void getPostLikeByUserAndPostId(String postId, String userId, DataOperationCallback<PostLike?> callback);

  Future<void> getLikesForPost(String postId, DataOperationCallback<List<PostLike>> callback);
  void removeLike(String postlikeId, String postId, OperationCallback callback);
}