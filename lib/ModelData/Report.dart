
class Report {
  String? reportid;
  String reporterid;
  String reportedid;
  String? reportingid;
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
    this.reportingid,
    required this.reporttype,
    required this.reason,
    required this.status,
    required this.createdon,
    this.username,
    this.userProfilePicture,
  });

  // Factory constructor to create Report instance from Firestore data
  factory Report.fromMap(Map<String, dynamic> data) {
    return Report(
      reportid: data['reportid'],
      reporterid: data['reporterid'],
      reportedid: data['reportedid'],
      reportingid: data['reportingid'],
      reporttype: data['reporttype'],
      reason: data['reason'],
      status: data['status'],
      createdon: data['createdon'],
      username: data['username'],
      userProfilePicture: data['userProfilePicture'],
    );
  }

  // Convert Report instance to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'reportid': reportid,
      'reporterid': reporterid,
      'reportedid': reportedid,
      'reportingid': reportingid,
      'reporttype': reporttype,
      'reason': reason,
      'status': status,
      'createdon': createdon,
      'username': username,
      'userProfilePicture': userProfilePicture,
    };
  }
}
