import 'package:flutter/material.dart';
import 'package:socialtrailsapp/ModelData/IssueWarning.dart';
import 'package:socialtrailsapp/Utility/IssueWarningService.dart';

class IssueWarningViewModel extends ChangeNotifier {
  List<IssueWarning> warnings = [];
  bool isLoading = false;
  String? errorMessage;

  // Method to fetch warnings from the database or service
  Future<void> fetchIssueWarnings() async {
    try {
      isLoading = true;
      errorMessage = null; // Reset previous error
      notifyListeners();

      warnings = await IssueWarningService().fetchWarnings(); // Fetch data
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load warnings: $e'; // Capture error if any
      notifyListeners();
    }
  }
}