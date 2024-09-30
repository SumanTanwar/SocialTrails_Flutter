
import '../ModelData/Users.dart';

import 'OperationCallback.dart';

abstract class IUserInterface {
  void createUser(Users user, OperationCallback callback);
  Future<Users?> getUserByID(String uid);

}
