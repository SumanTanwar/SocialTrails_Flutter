import 'package:socialtrailsapp/Interface/DataOperationCallback.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/ModelData/IssueWarning.dart';
import 'package:socialtrailsapp/ModelData/IssueWarningViewModel.dart';

abstract class IIssueWarning {
  Future<void> addWarning(IssueWarning data);
  Future<int> fetchWarningCount();
  Future<void> fetchWarnings(DataOperationCallback<List<IssueWarning>> callback);

}