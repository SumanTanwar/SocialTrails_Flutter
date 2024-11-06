import 'package:firebase_database/firebase_database.dart';
import 'package:socialtrailsapp/Interface/DataOperationCallback.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/ModelData/IssueWarning.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';
import 'package:socialtrailsapp/Interface/IIssueWarning.dart';
import 'package:socialtrailsapp/Interface/DataOperationCallback.dart';

class IssueWarningService implements IIssueWarning {
  final DatabaseReference _reference = FirebaseDatabase.instance.ref();
  final String _collectionName = 'issuewarning';
  final UserService userService = UserService();

  // Method to add a warning to the Firebase Realtime Database
  @override
  Future<void> addWarning(IssueWarning data) async {
    try {
      // Generate a new unique key for the warning
      String newItemKey = _reference.child(_collectionName).push().key ?? '';

      // Create a mutable copy of the data and assign the newItemKey
      data.issuewarningId = newItemKey;

      // Store the warning in Firebase
      await _reference.child(_collectionName).child(newItemKey).set(data.toMap());
    } catch (error) {
      print("Error adding warning: $error");
      throw Exception('Failed to add warning: $error');
    }
  }

  // Method to fetch warnings from Firebase
  @override
  Future<void> fetchWarnings(DataOperationCallback<List<IssueWarning>> callback) async {
    try {
      final DatabaseEvent event = await _reference.once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.children.isNotEmpty) {
        List<IssueWarning> warningsList = [];

        for (DataSnapshot dataSnapshot in snapshot.children) {
          if (dataSnapshot.value is Map) {
            final Map<dynamic, dynamic> mapValue = dataSnapshot.value as Map<dynamic, dynamic>;
            Map<String, dynamic> warningData = mapValue.map((key, value) => MapEntry(key.toString(), value));

            // Use 'fromMap' to create an IssueWarning instance
            IssueWarning warning = IssueWarning.fromMap(warningData);
            warning.issuewarningId = dataSnapshot.key;

            Users? userDetails = await getUserDetails(warning.issuewarnto);
            warning.username = userDetails?.username ?? "Unknown";
            warning.userprofilepicture = userDetails?.profilepicture;

            warningsList.add(warning);
          }
        }

        // Notify success via callback
        callback.onSuccess(warningsList);
      } else {
        callback.onFailure("No warnings found.");
      }
    } catch (e) {
      callback.onFailure("Error fetching warnings: ${e.toString()}");
    }
  }


  // Method to fetch the count of all warnings
  @override
  Future<int> fetchWarningCount() async {
    try {
      DatabaseEvent snapshot = await _reference.child(_collectionName).once();
      return snapshot.snapshot.children.length;
    } catch (error) {
      print("Error fetching warning count: $error");
      throw Exception('Failed to fetch warning count: $error');
    }
  }

  Future<Users?> getUserDetails(String userId) async {
    Users? user = await userService.getUserByID(userId);
    return user;
  }
}
