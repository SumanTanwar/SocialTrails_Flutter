
import 'package:socialtrailsapp/Interface/DataOperationCallback.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/ModelData/Report.dart';


abstract class IReport {
  Future<void> addReport(Report data, OperationCallback callback);
  Future<void> getReportCount(DataOperationCallback<int> callback);
  Future<void> fetchReports(DataOperationCallback<List<Report>> callback);
}


