import 'dart:io';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialtrailsapp/Interface/IUserInterface.dart';
import '../Interface/DataOperationCallback.dart';
import '../Interface/OperationCallback.dart';
import '../ModelData/Users.dart';
import 'package:socialtrailsapp/ModelData/UserRole.dart';
import 'Utils.dart';
import 'dart:typed_data';

class UserService extends IUserInterface {
  final DatabaseReference reference;
  final FirebaseStorage storage;
  static const String _collectionName = "users";

  UserService()
      : reference = FirebaseDatabase.instance.ref(),
        storage = FirebaseStorage.instance;

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
          return user;
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

  void setNotification(String userID, bool isEnabled, OperationCallback callback) {
    print("Setting notification for userID: $userID to $isEnabled");
    reference.child(_collectionName).child(userID).child("notification").set(isEnabled)
        .then((_) {
      print("Notification setting updated successfully for userID: $userID");
      callback.onSuccess();
    })
        .catchError((error) {
      print("Failed to update notification for userID: $userID. Error: $error");
      callback.onFailure(error.toString());
    });
  }

  void deleteProfile(String userID, OperationCallback callback) {
    reference.child(_collectionName).child(userID).remove().then((_) {
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
  Future<Users?> adminGetUserByID(String uid) async {
    try {
      final data = await reference.child(_collectionName).child(uid).once();
      if (data.snapshot.exists) {
        return Users.fromSnapshot(data.snapshot);
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
      'suspendedon': Utils.getCurrentDatetime(),
      'isActive': false,
      'isactive': false,
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
      'isactive': true,
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

  Future<List<Users>> getRegularUserList() async {
    List<Users> userList = [];
    final snapshot = await reference.child(_collectionName).once();
    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        userList.add(Users.fromMap(key, value));
      });
      print("Users loaded: ${userList.length}");
    } else {
      print("No users found");
    }
    return userList;
  }

  Future<List<Users>> getModeratorList() async {
    List<Users> moderatorsList = [];
    final snapshot = await reference.child(_collectionName).once();
    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value['roles'] == 'moderator' && value['profiledeleted'] == false) {
          moderatorsList.add(Users.fromMap(key, value));
        }
      });
      print("Moderators loaded: ${moderatorsList.length}");
    } else {
      print("No moderators found");
    }
    return moderatorsList;
  }

  Future<String> uploadProfileImage(String userId, File imageFile, DataOperationCallback<String> callback) async {
    try {
      String filePath = 'userprofile/$userId/${_generateUUID()}';
      Reference fileReference = storage.ref(filePath);
      if (await imageFile.exists()) {
        List<int> fileBytes = await imageFile.readAsBytes();
        await fileReference.putData(Uint8List.fromList(fileBytes));
        String downloadUrl = await fileReference.getDownloadURL();
        Map<String, dynamic> updates = {
          'profilepicture': downloadUrl,
        };
        await reference.child(_collectionName).child(userId).update(updates);
        callback.onSuccess(downloadUrl);
        return downloadUrl;
      } else {
        String errorMessage = "File does not exist: ${imageFile.path}";
        callback.onFailure(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      callback.onFailure("Error uploading image: ${e.toString()}");
      throw Exception("Error uploading image: ${e.toString()}");
    }
  }

  @override
  void updateNameAndBio(String userId, String name, String bio, OperationCallback callback) {
    Map<String, dynamic> updates = {
      'username': name,
      'bio': bio,
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
  void deleteUserProfile(String userId, OperationCallback callback) {

    reference.child(_collectionName).child(userId).child("profiledeleted").set(true)
  .then((_) {
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
  void unDeleteUserProfile(String userId, OperationCallback callback) {

    reference.child(_collectionName).child(userId).child("profiledeleted").set(false)
  .then((_) {
      if (callback != null) {
        callback.onSuccess();
      }
    }).catchError((error) {
      if (callback != null) {
        callback.onFailure(error.toString());
      }
    });
  }

  String _generateUUID() {
    return '${_randomString(8)}-${_randomString(4)}-${_randomString(4)}-${_randomString(4)}-${_randomString(12)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<List<Users>> getActiveUserList() async {
    try {
      final snapshot = await reference.child(_collectionName).once();
      List<Users> activeUsersList = [];

      // Check if the snapshot contains any data
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final user = Users.fromJson(value); // Ensure Users has a fromJson method

          // Check if the user meets the active criteria
          if (user.roles == UserRole.user.role && // Ensure UserRole is accessible
              !user.admindeleted &&
              !user.profiledeleted &&
              user.isactive) {
            activeUsersList.add(user);
          }
        });
      }

      return activeUsersList;
    } catch (error) {
      print("Error fetching active users: $error");
      throw error; // Handle the error as needed
    }
  }

}
