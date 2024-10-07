import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:socialtrailsapp/Interface/IUserInterface.dart';
import '../Interface/OperationCallback.dart';
import '../ModelData/Users.dart';
import 'Utils.dart';

class UserService extends IUserInterface {
  final DatabaseReference reference;
  static const String _collectionName = "users";

  UserService() : reference = FirebaseDatabase.instance.ref();

  // Create a new user
  @override
  void createUser(Users user, OperationCallback callback) {
    reference.child(_collectionName).child(user.userId)
        .set(user.toJson())
        .then((_) {
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
        Users user = Users.fromSnapshot(data.snapshot);
        if (!user.admindeleted && !user.profiledeleted) {
          return user; // User is valid
        } else {
          print("User is deleted by admin or profile is deleted.");
          return null;
        }
      } else {
        return null;
      }
    } catch (error) {
      print("Error retrieving user: $error");
      return null;
    }
  }

  Future<void> updateUser(Users user, OperationCallback callback) async {
    try {
      await reference.child(_collectionName).child(user.userId).update(
          user.toJson());
      callback.onSuccess();
    } catch (error) {
      callback.onFailure(error.toString());
    }
  }

  void setNotification(String userID, bool isEnabled, OperationCallback callback) {
    print("Setting notification for userID: $userID to $isEnabled"); // Log the action

    reference.child(_collectionName).child(userID).child("notification").set(isEnabled)
        .then((_) {
      print("Notification setting updated successfully for userID: $userID"); // Log success
      callback.onSuccess();
    })
        .catchError((error) {
      print("Failed to update notification for userID: $userID. Error: $error"); // Log error
      callback.onFailure(error.toString());
    });
  }

  void setbackdeleteProfile(String userID) {
    // This function logs the setback for deleting a profile
    debugPrint("Setback delete profile for user: $userID");
  }

  void deleteProfile(String userID, OperationCallback callback) {
    reference.child(_collectionName).child(userID).remove().then((_) {
      // On success
      if (callback != null) {
        callback.onSuccess();
      }
    }).catchError((error) {
      // On failure
      if (callback != null) {
        callback.onFailure(error.toString());
      }
    });
  }
  @override
  Future<Users?> adminGetUserByID(String uid) async {
    try {
      final data = await reference.child(_collectionName).child(uid).once();

      if (data.snapshot.exists) {
        return Users.fromSnapshot(
            data.snapshot);
      } else {
        return null;
      }
    } catch (error) {
      print("Error retrieving user: $error");
      return null;
    }
  }
  @override
  void suspendProfile(String userId, String suspendedBy, String reason, OperationCallback callback) {
    Map<String, dynamic> updates = {
      'suspended': true,
      'suspendedby': suspendedBy,
      'suspendedreason': reason,
      'suspendedon': Utils.getCurrentDatetime(), // You may need to implement this method
      'isActive': false,
    };

    reference.child(_collectionName).child(userId).update(updates).then((_) {
      if (callback != null) {
        callback.onSuccess();
      }
    }).catchError((error) {
      if (callback != null) {
        callback.onFailure(error.toString());
      }
    });
  }
  @override
  void activateProfile(String userId, OperationCallback callback) {
    Map<String, dynamic> updates = {
      'suspended': false,
      'suspendedby': null,
      'suspendedreason': null,
      'suspendedon': null,
      'isActive': true,
    };

    reference.child(_collectionName).child(userId).update(updates).then((_) {
      if (callback != null) {
        callback.onSuccess();
      }
    }).catchError((error) {
      if (callback != null) {
        callback.onFailure(error.toString());
      }
    });
  }
  @override
  void adminDeleteProfile(String userId, OperationCallback callback) {
    Map<String, dynamic> updates = {
      "admindeleted": true,
      "admindeletedon": Utils.getCurrentDatetime(),
      "isactive": false,
    };

    reference.child(_collectionName).child(userId).update(updates).then((_) {
      if (callback != null) {
        callback.onSuccess();
      }
    }).catchError((error) {
      if (callback != null) {
        callback.onFailure(error.toString());
      }
    });
  }
  @override
  void adminUnDeleteProfile(String userId, OperationCallback callback) {
    Map<String, dynamic> updates = {
      "admindeleted": false,
      "admindeletedon": null,
      "isactive": true,
    };

    reference.child(_collectionName).child(userId).update(updates).then((_) {
      if (callback != null) {
        callback.onSuccess();
      }
    }).catchError((error) {
      if (callback != null) {
        callback.onFailure(error.toString());
      }
    });
  }

}

