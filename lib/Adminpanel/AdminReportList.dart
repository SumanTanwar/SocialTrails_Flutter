import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Adminpanel/adminpostmanage.dart';
import 'package:socialtrailsapp/ModelData/Report.dart';
import 'package:socialtrailsapp/Utility/ReportService.dart';
import 'package:socialtrailsapp/Utility/UserPostService.dart';
import '../AdminPanel/adminusermanage.dart';
import '../ModelData/ReportType.dart';
import '../Interface/DataOperationCallback.dart';
import 'package:socialtrailsapp/WarningPopup.dart';

import '../ModelData/UserPost.dart';

class AdminReportListScreen extends StatefulWidget {
  @override
  _AdminReportListScreenState createState() => _AdminReportListScreenState();
}

class _AdminReportListScreenState extends State<AdminReportListScreen> {
  final ReportService reportService = ReportService();
  List<Report> reportsWithUserInfo = [];

  bool _isPopupVisible = false;
  String _issueWarnId = '';
  String _issueWarnto = '';
  String _warningType = '';

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    print("Fetching reports...");
    reportService.fetchReports(DataOperationCallback<List<Report>>(
      onSuccess: (fetchedReports) {
        print("Reports fetched successfully: ${fetchedReports.length}");
        setState(() {
          reportsWithUserInfo = fetchedReports;
        });
      },
      onFailure: (error) {
        // Handle error (e.g., show a Snackbar or AlertDialog)
        print("Error fetching reports: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching reports: $error")),
        );
      },
    ));
  }

  void _showWarningPopup(String issueWarnId, String issueWarnto, String warningType) {
    setState(() {
      _isPopupVisible = true;
      _issueWarnId = issueWarnId;
      _issueWarnto = issueWarnto;
      _warningType = warningType;
    });

    if (warningType == 'post') {
      UserPostService().getUserPostDetailById(issueWarnId, DataOperationCallback<UserPost>(
        onSuccess: (userPost) {

          setState(() {
            _issueWarnto = userPost.userId;
          });
        },
        onFailure: (error) {
          print('Failed to fetch user post details: $error');
        },
      ));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Reports"),
        centerTitle: true,
      ),
      body: reportsWithUserInfo.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: reportsWithUserInfo.length,
        itemBuilder: (context, index) {
          return reportRow(reportsWithUserInfo[index]);
        },
      ),

      // Show the WarningPopup if the flag is set to true
      floatingActionButton: _isPopupVisible
          ? WarningPopup(
        isPresented: _isPopupVisible,
        issueWarnId: _issueWarnId,
        issueWarnto: _issueWarnto,
        warningType: _warningType,
        onDismiss: (bool success) {
          setState(() {
            _isPopupVisible = false;
          });
        },
      )
          : Container(),



    );
  }

  Widget reportRow(Report report) {
    return ListTile(
      leading: report.userProfilePicture != null && report.userProfilePicture!.isNotEmpty
          ? CircleAvatar(
        backgroundImage: NetworkImage(report.userProfilePicture!),
        radius: 25,
      )
          : CircleAvatar(
        child: Icon(Icons.person),
        radius: 25,
        backgroundColor: Colors.grey,
      ),
      title: Text(report.username ?? "Unknown"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(report.createdon, style: TextStyle(color: Colors.grey)),
          Text("Type: ${report.reporttype}", style: TextStyle(color: Colors.grey)),
          Text("Status: ${report.status}", style: TextStyle(color: Colors.grey)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.visibility, color: Colors.black),
            onPressed: () {
              if (report.reporttype == ReportType.post.getType()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminPostDetailScreen(postId: report.reportedid),
                  ),
                );
              } else if (report.reporttype == ReportType.user.getType()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminUserDetailManageScreen(userId: report.reportedid),
                  ),
                );
              } else {
                // Handle invalid report type
                print("No valid action for this report type");
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.warning, color: Colors.black), // Warning icon
            onPressed: () {
              _showWarningPopup(report.reportedid, report.reportedid ?? "Unknown", report.reporttype);
            },
          ),
        ],
      ),
    );
  }
}
