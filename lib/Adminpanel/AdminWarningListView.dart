import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialtrailsapp/ModelData/IssueWarning.dart';
import 'package:socialtrailsapp/ModelData/IssueWarningViewModel.dart';
import 'package:socialtrailsapp/Utility/IssueWarningService.dart';
import 'package:socialtrailsapp/Interface/DataOperationCallback.dart';

class AdminWarningListView extends StatefulWidget {
  @override
  _AdminWarningListViewState createState() => _AdminWarningListViewState();
}

class _AdminWarningListViewState extends State<AdminWarningListView> {
  final IssueWarningService warningService = IssueWarningService();
  List<IssueWarning> warningsList = [];

  @override
  void initState() {
    super.initState();
    fetchWarnings();
  }

  Future<void> fetchWarnings() async {
    print("Fetching warnings...");

    warningService.fetchWarnings(DataOperationCallback<List<IssueWarning>>(
      onSuccess: (fetchedWarnings) {
        print("Warnings fetched successfully: ${fetchedWarnings.length}");

        setState(() {

          warningsList = fetchedWarnings;
        });
      },
      onFailure: (error) {
        // Handle error (e.g., show a Snackbar or AlertDialog)
        print("Error fetching warnings: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching warnings: $error")),
        );
      },
    ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issued Warning List"),
        centerTitle: true,
      ),
      body: warningsList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: warningsList.length,
        itemBuilder: (context, index) {
          return WarningRow(warning: warningsList[index]);
        },
      ),
    );
  }
}

class WarningRow extends StatelessWidget {
  final IssueWarning warning;

  WarningRow({required this.warning});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: warning.userprofilepicture != null && warning.userprofilepicture!.isNotEmpty
          ? CircleAvatar(
        backgroundImage: NetworkImage(warning.userprofilepicture!),
        radius: 25,
      )
          : CircleAvatar(
        child: Icon(Icons.person),
        radius: 25,
        backgroundColor: Colors.grey,
      ),
      title: Text(warning.username ?? "Unknown User"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Reason: ${warning.reason}", style: TextStyle(color: Colors.black)),
          Text("Warning Type: ${warning.warningtype}", style: TextStyle(color: Colors.black)),
          Text("Issued by: ${warning.issuewarnby}", style: TextStyle(color: Colors.black)),
          Text("Issued On: ${warning.createdon}", style: TextStyle(color: Colors.grey)),
        ],
      ),
      isThreeLine: true, // Makes the subtitle a multi-line area
    );
  }
}
