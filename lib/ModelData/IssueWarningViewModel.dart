import 'package:flutter/material.dart';
import 'package:socialtrailsapp/ModelData/IssueWarning.dart';
import 'package:socialtrailsapp/Utility/IssueWarningService.dart';
import 'package:socialtrailsapp/Interface/DataOperationCallback.dart';

class IssueWarningViewModel extends ChangeNotifier {
  List<IssueWarning> warnings = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchIssueWarnings() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      DataOperationCallback<List<IssueWarning>> callback = DataOperationCallback<List<IssueWarning>>(
        onSuccess: (fetchedWarnings) {
          warnings = fetchedWarnings;
          isLoading = false;
          notifyListeners();
        },
        onFailure: (error) {
          errorMessage = 'Failed to load warnings: $error';
          isLoading = false;
          notifyListeners();
        },
      );

      // Pass the callback to fetchWarnings
      await IssueWarningService().fetchWarnings(callback);  // Pass the callback here
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load warnings: $e';
      notifyListeners();
    }
  }
}
