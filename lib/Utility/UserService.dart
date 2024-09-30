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
  @override
  Future<Users?> getUserByID(String uid) async {
    try {
      final data = await reference.child(_collectionName).child(uid).once();

      if (data.snapshot.exists) {
        return Users.fromSnapshot(data.snapshot); // Implement fromSnapshot method in Users
      } else {
        return null; // User not found
      }
    } catch (error) {
      print("Error retrieving user: $error");
      return null; // Handle the error as needed
    }
  }

}


