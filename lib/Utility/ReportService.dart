import 'package:firebase_database/firebase_database.dart';
import 'package:socialtrailsapp/Interface/DataOperationCallback.dart';
import 'package:socialtrailsapp/Interface/IReport.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/ModelData/Report.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';

import '../ModelData/Users.dart';

class ReportService implements IReport {
  final DatabaseReference reference;
  static const String _collectionName = "report";
  final UserService userService;

  ReportService()
      : reference = FirebaseDatabase.instance.ref(_collectionName),
        userService = UserService();

  @override
  Future<void> addReport(Report data, OperationCallback callback) async {
    try {
      String newItemKey = reference
          .push()
          .key!;
      data.reportid = newItemKey;
      await reference.child(newItemKey).set(data.toMap());
      callback.onSuccess();
    } catch (e) {
      callback.onFailure("Failed to add report: ${e.toString()}");
    }
  }

  @override
  Future<void> getReportCount(DataOperationCallback<int> callback) async {
    try {
      final DatabaseEvent event = await reference.once();
      final DataSnapshot snapshot = event.snapshot;
      int count = snapshot.children.length;
      callback.onSuccess(count);
    } catch (e) {
      callback.onFailure("Error fetching report count: ${e.toString()}");
    }
  }

  @override
  Future<void> fetchReports(DataOperationCallback<List<Report>> callback) async {
    try {
      print("Attempting to fetch reports...");
      final DatabaseEvent event = await reference.once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.children.isNotEmpty) {
        List<Report> reportsList = [];

        for (DataSnapshot dataSnapshot in snapshot.children) {
          print("Processing report snapshot: ${dataSnapshot.key}");
          print("Value type: ${dataSnapshot.value.runtimeType}");

          // Check if the value is a Map and is not null
          if (dataSnapshot.value is Map) {
            // Safely cast to Map<dynamic, dynamic>
            final Map<dynamic, dynamic> mapValue = dataSnapshot.value as Map<dynamic, dynamic>;

            // Create a Map<String, dynamic> from the dynamic map
            Map<String, dynamic> reportData = mapValue.map((key, value) => MapEntry(key.toString(), value));

            Report report = Report.fromJson(reportData);

            // Fetch user details for the reporter
            Users? userDetails = await getUserDetails(report.reporterid);
            report.username = userDetails?.username ?? "Unknown"; // Default to "Unknown" if user is not found
            report.userProfilePicture = userDetails?.profilepicture; // Handle profile picture

            reportsList.add(report);
          } else {
            print("Snapshot value is null or not a Map");
          }
        }

        callback.onSuccess(reportsList);
      } else {
        callback.onFailure("No reports found.");
      }
    } catch (e) {
      callback.onFailure("Error fetching reports: ${e.toString()}");
    }
  }

  Future<Users?> getUserDetails(String userId) async {
    Users? user = await userService.getUserByID(userId);
    return user;
  }

}