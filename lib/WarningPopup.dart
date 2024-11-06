import 'package:flutter/material.dart';

import 'package:socialtrailsapp/ModelData/IssueWarning.dart';
import 'package:socialtrailsapp/Utility/IssueWarningService.dart';
import 'package:socialtrailsapp/Utility/NotificationService.dart';

class WarningPopup extends StatefulWidget {
  final bool isPresented;
  final String issueWarnId;
  final String issueWarnto;
  final String warningType;
  final Function(bool) onDismiss;

  WarningPopup({
    required this.isPresented,
    required this.issueWarnId,
    required this.issueWarnto,
    required this.warningType,
    required this.onDismiss,
  });

  @override
  _WarningPopupState createState() => _WarningPopupState();
}

class _WarningPopupState extends State<WarningPopup> {
  TextEditingController _warningReasonController = TextEditingController();
  String? alertMessage;
  bool showAlert = false;

  @override
  Widget build(BuildContext context) {
    return widget.isPresented
        ? GestureDetector(
      onTap: () {
        widget.onDismiss(false); // Close the popup when tapping outside
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Updated to use 'titleLarge' (formerly headline6)
                  Text('Issue Warning', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 10),
                  Text('Why are you issuing this warning?', style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 10),
                  Text(
                    'Your warning is anonymous. If someone is in immediate danger, call the local emergency service.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _warningReasonController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter reason for warning',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _submitWarning,
                        child: Text('Submit Warning'),
                      ),
                      ElevatedButton(
                        onPressed: () => widget.onDismiss(false),
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                  if (showAlert)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        alertMessage ?? 'An error occurred.',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    )
        : Container();
  }

  // Mark this method as 'async'
  Future<void> _submitWarning() async {
    String warningReason = _warningReasonController.text.trim();

    if (warningReason.isEmpty) {
      setState(() {
        alertMessage = 'Please enter a reason for reporting.';
        showAlert = true;
      });
      return;
    }

    // Assuming you have a method to get the current user
    String currentUser = 'Admin'; // Replace with the actual user
    IssueWarning warning = IssueWarning(
      issuewarnby: currentUser,
      issuewarnto: widget.issueWarnto,
      issuewarnId: widget.issueWarnId,
      warningtype: widget.warningType,
      reason: warningReason,
    );

    try {
      // Now the addWarning method can be awaited since _submitWarning is async
      await IssueWarningService().addWarning(warning);

      // // Send notification on success
      // NotificationService().sendNotificationToUser(
      //   Notification(
      //     notifyto: widget.issueWarnto,
      //     notifyBy: currentUser,
      //     type: widget.warningType,
      //     message: warningReason,
      //     relatedId: widget.issueWarnId,
      //   ),
      // );

      setState(() {
        alertMessage = 'Warning submitted successfully!';
        showAlert = true;
      });
      widget.onDismiss(true); // Close the popup
    } catch (error) {
      setState(() {
        alertMessage = 'Failed to submit warning: $error';
        showAlert = true;
      });
    }
  }
}
