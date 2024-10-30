
import 'package:socialtrailsapp/ModelData/Report.dart';

import 'DataOperationCallback.dart';
import 'OperationCallback.dart';


abstract class IReport {
  Future<void> addReport(Report data, OperationCallback callback);
  Future<void> getReportCount(DataOperationCallback<int> callback);
  Future<void> fetchReports(DataOperationCallback<List<Report>> callback);
}

