import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Utils {
  // Get current date and time in the specified format
  static String getCurrentDatetime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }


  // Validate password to ensure it contains at least one letter and one digit
  static bool isValidPassword(String password) {
    bool hasLetter = false;
    bool hasDigit = false;

    for (int i = 0; i < password.length; i++) {
      if (RegExp(r'[a-zA-Z]').hasMatch(password[i])) {
        hasLetter = true;
      } else if (RegExp(r'[0-9]').hasMatch(password[i])) {
        hasDigit = true;
      }
      if (hasLetter && hasDigit) {
        return true;
      }
    }
    return false;
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)));
  }

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)));
  }

  static Future<void> removeRememberCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_username');
    await prefs.remove('remember_me');
  }
  static String getRelativeTime(String? dateString) {
    final DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
    try {
      DateTime date = format.parse(dateString!);
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(date);

      if (diff.inMinutes < 1) {
        return "posted recently";
      } else if (diff.inDays < 1) {
        return "${diff.inHours} hour${diff.inHours != 1 ? 's' : ''} ago"; // Adjust for pluralization
      } else {
        final DateFormat outputFormat = DateFormat('MMM d');
        return "on ${outputFormat.format(date)}";
      }
    } catch (e) {
      print("Error parsing date: $e");
    }
    return "";
  }
}