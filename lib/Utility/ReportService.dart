// lib/services/report_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:socialtrailsapp/Interface/IReport.dart';
import 'package:socialtrailsapp/ModelData/Report.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';

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
      String newItemKey = reference.push().key!; // Generate a new key for the report
      data.reportId = newItemKey; // Set the report ID
      await reference.child(newItemKey).set(data.toMap()); // Save the report data
      callback(true, "Report added successfully."); // Call success callback
    } catch (e) {
      callback(false, e.toString()); // Call failure callback with the error message
    }
  }

  @override
  Future<void> getReportCount(DataOperationCallback<int> callback) async {
    try {
      final DatabaseEvent event = await reference.once(); // Get the database event
      final DataSnapshot snapshot = event.snapshot; // Get the snapshot from the event
      int count = snapshot.children.length; // Count the number of reports
      callback(count, "Report count fetched successfully."); // Call success callback
    } catch (e) {
      callback(0, e.toString()); // Call failure callback with the error message
    }
  }

  @override
  Future<void> fetchReports(DataOperationCallback<List<Report>> callback) async {
    try {
      final DatabaseEvent event = await reference.once(); // Get the database event
      final DataSnapshot snapshot = event.snapshot; // Get the snapshot from the event
      List<Report> reportsList = [];

      if (snapshot.exists) {
        int totalReports = snapshot.children.length;
        int processedReports = 0;

        for (DataSnapshot dataSnapshot in snapshot.children) {
          // Ensure that the data is a Map
          if (dataSnapshot.value is Map<String, dynamic>) {
            Report report = Report.fromMap(dataSnapshot.value as Map<String, dynamic>);

            // Fetch the user by ID asynchronously
            Users? user = await userService.getUserByID(report.reporterId);
            report.username = user?.username ?? "Unknown";
          //  report.userProfilePicture = user?.userProfilePicture;

            reportsList.add(report); // Add report to the list
            processedReports++;

            // Check if all reports have been processed
            if (processedReports == totalReports) {
              callback(reportsList, "Reports fetched successfully."); // Call success callback
            }
          } else {
            processedReports++;
            if (processedReports == totalReports) {
              callback(reportsList, "Reports fetched successfully.");
            }
          }
        }
      } else {
        callback([], "No reports found."); // No reports scenario
      }
    } catch (e) {
      callback([], "Error fetching reports: ${e.toString()}"); // Call failure callback
    }
  }
}
