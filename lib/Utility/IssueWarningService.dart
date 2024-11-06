import 'package:firebase_database/firebase_database.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/ModelData/IssueWarning.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';
import 'package:socialtrailsapp/Interface/IIssueWarning.dart';

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
  Future<List<IssueWarning>> fetchWarnings() async {
    try {
      DataSnapshot snapshot = await _reference.child(_collectionName).get();
      if (snapshot.exists) {
        final warningDicts = snapshot.value as Map<dynamic, dynamic>;
        List<IssueWarning> warnings = [];

        // Iterate over each warning in the collection
        for (var warningId in warningDicts.keys) {
          var warningData = warningDicts[warningId];

          // Ensure we get a Map<String, dynamic> for each warning
          if (warningData is Map<String, dynamic>) {
            IssueWarning warning = IssueWarning.fromMap(warningData);
            warning.issuewarningId = warningId;

            warnings.add(warning);
          }
        }
        return warnings;
      } else {
        print("No data exists in Firebase under 'issuewarning'");
        return []; // Return an empty list if no data
      }
    } catch (error) {
      print("Error fetching warnings: $error");
      throw Exception('Failed to fetch warnings: $error');
    }
  }

  // Method to retrieve user details
  Future<Users> retrieveUserDetails(String userId) async {
    try {
      var userDetails = await userService.getUserByID(userId);
      if (userDetails == null) {
        throw Exception('User details not found for userId: $userId');
      }
      return userDetails;
    } catch (error) {
      print("Error retrieving user details: $error");
      throw Exception('Error retrieving user details: $error');
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
}
