import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';
import '../Utility/Utils.dart';

class AdminUserDetailManageScreen extends StatefulWidget {
  final String userId;

  AdminUserDetailManageScreen({required this.userId});

  @override
  _AdminUserDetailManageScreenState createState() => _AdminUserDetailManageScreenState();
}

class _AdminUserDetailManageScreenState extends State<AdminUserDetailManageScreen> {
  Users? user;
  bool isLoading = true;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    user = await userService.adminGetUserByID(widget.userId);
    setState(() {
      isLoading = false;
    });
  }

  void _showSuspendDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Suspend Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please provide a reason for suspending ${user?.username}'s profile:"),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(labelText: 'Suspend Reason'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  Utils.showError(context, "Suspend reason is required");
                } else {
                  _suspendProfile(widget.userId, reason);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Confirm"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _suspendProfile(String userId, String reason) {
    userService.suspendProfile(userId, SessionManager().getUserID() ?? "", reason, OperationCallback(
      onSuccess: () {
        setState(() {
          user?.suspended = true;
          user?.suspendedreason = "Suspended profile: ${reason}";
        });
        Utils.showMessage(context, "Profile suspended successfully.");
      },
      onFailure: (errMessage) {
        Utils.showError(context, "suspend profile failed! Please try again later.");
      },
    ));
  }

  void _activateProfile(String userId) {
    userService.activateProfile(userId, OperationCallback(
      onSuccess: () {
        setState(() {
          user?.suspended = false;
          user?.suspendedreason = "";
        });
        Utils.showMessage(context, "Profile activated successfully.");
      },
      onFailure: (errMessage) {
        Utils.showError(context, "activate profile failed! Please try again later.");
      },
    ));
  }

  void _deleteProfile(String userId) {
    // Implement delete functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: const EdgeInsets.only(top: 50),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/user.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        user?.username ?? 'Unknown User',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  ProfileStat(count: '0', label: 'Posts'),
                  SizedBox(width: 15),
                  ProfileStat(count: '0', label: 'Followers'),
                  SizedBox(width: 15),
                  ProfileStat(count: '0', label: 'Followings'),
                ],
              ),
              SizedBox(height: 2),
              UserDetailText(label: user?.bio ?? ''),
              UserDetailText(label: user?.email ?? ''),
              SizedBox(height: 5),
              UserDetailText(
                label: user?.suspendedreason ?? '',
                isVisible: user?.suspended ?? false,
                textColor: user?.suspended == true ? Colors.white : Colors.black,
                backgroundColor: user?.suspended == true ? Color(0xFFFF9800) : Colors.transparent,
              ),
              SizedBox(height: 5),
              UserDetailText(label: 'Delete reason (if any)', isVisible: user?.admindeleted ?? false),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: SizedBox(
                      width: 150,
                      child: ProfileButton(
                        label: user?.suspended == true ? 'UnSuspend Profile' : 'Suspend Profile',
                        onPressed: user?.suspended == true ? () => _activateProfile(widget.userId) : _showSuspendDialog,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: ProfileButton(
                      label: user?.admindeleted == true ? 'Activate Profile' : 'Delete Profile',
                      onPressed: user?.admindeleted == true ? () => _deleteProfile(widget.userId) : () => _deleteProfile(widget.userId),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String count;
  final String label;

  ProfileStat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ],
    );
  }
}

class UserDetailText extends StatelessWidget {
  final String label;
  final bool isVisible;
  final Color textColor;
  final Color backgroundColor;

  UserDetailText({
    required this.label,
    this.isVisible = true,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return isVisible
        ? Container(
      color: backgroundColor,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 30),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: textColor),
      ),
    )
        : SizedBox.shrink();
  }
}

class ProfileButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  ProfileButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: Colors.black),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
