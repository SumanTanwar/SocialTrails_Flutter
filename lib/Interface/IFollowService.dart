abstract class IFollowService
{
  Future<List<String>> getFollowAndFollowerIdsByUserId(String userId);
}