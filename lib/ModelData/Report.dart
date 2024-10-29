
class Report {
  String? reportId;
  String reporterId;
  String reportedId;
  String? reportingId;
  String reportType;
  String reason;
  String status;
  String createdOn;
  String? username;
  String? userProfilePicture;

  Report({
    this.reportId,
    required this.reporterId,
    required this.reportedId,
    this.reportingId,
    required this.reportType,
    required this.reason,
    required this.status,
    required this.createdOn,
    this.username,
    this.userProfilePicture,
  });

  // Factory constructor to create Report instance from Firestore data
  factory Report.fromMap(Map<String, dynamic> data) {
    return Report(
      reportId: data['reportId'],
      reporterId: data['reporterId'],
      reportedId: data['reportedId'],
      reportingId: data['reportingId'],
      reportType: data['reportType'],
      reason: data['reason'],
      status: data['status'],
      createdOn: data['createdOn'],
      username: data['username'],
      userProfilePicture: data['userProfilePicture'],
    );
  }

  // Convert Report instance to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reporterId': reporterId,
      'reportedId': reportedId,
      'reportingId': reportingId,
      'reportType': reportType,
      'reason': reason,
      'status': status,
      'createdOn': createdOn,
      'username': username,
      'userProfilePicture': userProfilePicture,
    };
  }
}
