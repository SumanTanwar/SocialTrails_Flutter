
import 'package:socialtrailsapp/ModelData/Report.dart';

typedef OperationCallback = void Function(bool success, String message);
typedef DataOperationCallback<T> = void Function(T result, String message);

abstract class IReport {
  Future<void> addReport(Report data, OperationCallback callback);
  Future<void> getReportCount(DataOperationCallback<int> callback);
  Future<void> fetchReports(DataOperationCallback<List<Report>> callback);
}

