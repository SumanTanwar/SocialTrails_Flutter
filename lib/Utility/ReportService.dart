

import 'package:firebase_database/firebase_database.dart';
import 'package:socialtrailsapp/Interface/DataOperationCallback.dart';
import 'package:socialtrailsapp/Interface/IReport.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/ModelData/Report.dart';
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
      String newItemKey = reference.push().key!;
      data.reportid = newItemKey;
      await reference.child(newItemKey).set(data.toMap());
      callback.onSuccess();
    } catch (e) {
      callback.onFailure(e.toString());
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
      callback.onFailure(e.toString());
    }
  }

  @override
  Future<void> fetchReports(DataOperationCallback<List<Report>> callback) async {
    try {
      final DatabaseEvent event = await reference.once();
      final DataSnapshot snapshot = event.snapshot;
      List<Report> reportsList = [];

      if (snapshot.exists) {
        List<Future<void>> userFetchFutures = [];

        for (DataSnapshot dataSnapshot in snapshot.children) {
          if (dataSnapshot.value is Map<String, dynamic>) {
            Report report = Report.fromMap(dataSnapshot.value as Map<String, dynamic>);
            userFetchFutures.add(
              userService.getUserByID(report.reporterid).then((user) {
                report.username = user?.username ?? "Unknown";
                reportsList.add(report);
              }),
            );
          }
        }

        await Future.wait(userFetchFutures);
        callback.onSuccess(reportsList);
      } else {
        callback.onFailure("No reports found.");
      }
    } catch (e) {
      callback.onFailure("Error fetching reports: ${e.toString()}");
    }
  }
}

