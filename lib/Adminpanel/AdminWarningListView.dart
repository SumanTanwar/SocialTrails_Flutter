import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialtrailsapp/ModelData/IssueWarning.dart';
import 'package:socialtrailsapp/ModelData/IssueWarningViewModel.dart';

class AdminWarningListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch the view model for changes
    return ChangeNotifierProvider(
      create: (_) => IssueWarningViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Issued Warnings"),
          centerTitle: true,
        ),
        body: Consumer<IssueWarningViewModel>(
          builder: (context, viewModel, child) {
            // Check if the ViewModel is loading
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            // Check if there is an error
            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.errorMessage!),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.fetchIssueWarnings(); // Retry fetch
                      },
                      child: Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            // Display the warnings
            return ListView.builder(
              itemCount: viewModel.warnings.length,
              itemBuilder: (context, index) {
                return WarningRow(warning: viewModel.warnings[index]);
              },
            );
          },
        ),
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
