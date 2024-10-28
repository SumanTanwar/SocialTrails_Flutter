import '../ModelData/PostComment.dart';

abstract class IPostComment{
  Future<void> retrieveComments(String postId, Function(List<PostComment>) onSuccess, Function(String) onFailure);

}