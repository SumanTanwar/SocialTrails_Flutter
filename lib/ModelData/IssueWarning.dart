import 'dart:convert';
import 'package:socialtrailsapp/Utility/Utils.dart';

class IssueWarning {
  String? issuewarningId;
  String issuewarnby;
  String issuewarnto;
  String issuewarnId;
  String warningtype;
  String reason;
  String createdon;
  String? username;
  String? userprofilepicture;

  // Constructor to initialize with required parameters
  IssueWarning({
    this.issuewarningId,
    required this.issuewarnby,
    required this.issuewarnto,
    required this.issuewarnId,
    required this.warningtype,
    required this.reason,
    String? createdon,
    this.username,
    this.userprofilepicture,
  }) : createdon = createdon ?? Utils.getCurrentDatetime();

  // Factory constructor to create an instance from a Map (dictionary-like structure)
  factory IssueWarning.fromMap(Map<String, dynamic> map) {
    return IssueWarning(
      issuewarningId: map['issuewarningId'],
      issuewarnby: map['issuewarnby'] ?? 'Unknown',
      issuewarnto: map['issuewarnto'] ?? 'Unknown',
      issuewarnId: map['issuewarnId'] ?? 'UUID', // Default UUID or use your logic
      warningtype: map['warningtype'] ?? 'General', // Default warning type
      reason: map['reason'] ?? 'No reason provided', // Default reason
      createdon: map['createdon'] ?? Utils.getCurrentDatetime(), // Default created time
      username: map['username'],
      userprofilepicture: map['userprofilepicture'],
    );
  }

  // Method to convert the instance to a Map (dictionary-like structure)
  Map<String, dynamic> toMap() {
    return {
      'issuewarningId': issuewarningId,
      'issuewarnby': issuewarnby,
      'issuewarnto': issuewarnto,
      'issuewarnId': issuewarnId,
      'warningtype': warningtype,
      'reason': reason,
      'createdon': createdon,
      'username': username,
      'userprofilepicture': userprofilepicture,
    };
  }

  // Method to convert the instance to a JSON string
  String toJson() => json.encode(toMap());

  // Factory method to create a list of IssueWarnings from a list of maps (useful for backend JSON response)
  static List<IssueWarning> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => IssueWarning.fromMap(map)).toList();
  }
}
