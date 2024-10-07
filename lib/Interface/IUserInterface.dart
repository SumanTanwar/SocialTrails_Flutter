
import '../ModelData/Users.dart';

import 'OperationCallback.dart';

abstract class IUserInterface {
  void createUser(Users user, OperationCallback callback);
  Future<Users?> getUserByID(String uid);
  Future<Users?> adminGetUserByID(String uid);
  void suspendProfile(String userId, String suspendedBy, String reason, OperationCallback callback);
  void activateProfile(String userId, OperationCallback callback);
  void adminDeleteProfile(String userId, OperationCallback callback);
  void adminUnDeleteProfile(String userId, OperationCallback callback);
  void updateUserInfo(String username, String email, String bio);
}
