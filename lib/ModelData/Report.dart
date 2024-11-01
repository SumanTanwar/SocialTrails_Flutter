class Report {
  String? reportid; // This can remain as is
  String reporterid; // Change casing if necessary
  String reportedid; // Change casing if necessary
  String reporttype;
  String reason;
  String status;
  String createdon;
  String? username;
  String? userProfilePicture;

  Report({
    this.reportid,
    required this.reporterid,
    required this.reportedid,
    required this.reporttype,
    required this.reason,
    required this.status,
    required this.createdon,
    this.username,
    this.userProfilePicture,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportid: json['reportId'] as String? ?? '', // Corrected field name
      reporterid: json['reporterId'] as String? ?? '', // Corrected field name
      reportedid: json['reportedId'] as String? ?? '', // Corrected field name
      reporttype: json['reporttype'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdon: json['createdon'] as String? ?? '',
      username: json['username'] as String? ?? 'Unknown', // Fallback to 'Unknown'
      userProfilePicture: json['userProfilePicture'] as String?, // This can be null
    );
  }

  // Convert Report instance to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'reportId': reportid, // Corrected field name for saving
      'reporterId': reporterid, // Corrected field name for saving
      'reportedId': reportedid, // Corrected field name for saving
      'reporttype': reporttype,
      'reason': reason,
      'status': status,
      'createdon': createdon,
    };
  }
}
