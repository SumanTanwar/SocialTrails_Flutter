import 'package:firebase_database/firebase_database.dart';
import 'package:socialtrailsapp/Interface/IUserInterface.dart';

import '../Interface/OperationCallback.dart';
import '../ModelData/Users.dart';


class UserService extends IUserInterface{
  final DatabaseReference reference;
  static const String _collectionName = "users";

  UserService() : reference = FirebaseDatabase.instance.ref();

  // Create a new user
  @override
  void createUser(Users user, OperationCallback callback) {
    reference.child(_collectionName).child(user.userId).set(user.toJson()).then((_) {
      callback.onSuccess();
    }).catchError((error) {
      callback.onFailure(error.toString());
    });
  }


}
