
import 'dart:io';

import '../ModelData/Users.dart';

import 'DataOperationCallback.dart';
import 'OperationCallback.dart';

abstract class IUserInterface {
  void createUser(Users user, OperationCallback callback);
  Future<Users?> getUserByID(String uid);
  Future<Users?> adminGetUserByID(String uid);
  void suspendProfile(String userId, String suspendedBy, String reason, OperationCallback callback);
  void activateProfile(String userId, OperationCallback callback);
  void adminDeleteProfile(String userId, OperationCallback callback);
  void adminUnDeleteProfile(String userId, OperationCallback callback);
  Future<String?>  uploadProfileImage(String userId, File imageFile, DataOperationCallback<String> callback);
  void deleteUserProfile(String userId, OperationCallback callback);
  void unDeleteUserProfile(String userId, OperationCallback callback);
}
