import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Adminpanel/adminpostmanage.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';
import 'package:socialtrailsapp/main.dart';
import '../Interface/DataOperationCallback.dart';
import '../ModelData/PostImageData.dart';
import '../ModelData/UserPost.dart';
import '../Utility/UserPostService.dart';
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
  String deleteProfileStatus = "";
  List<PostImageData> _postImages = [];
  int postsCount = 0;
  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    user = await userService.adminGetUserByID(widget.userId);

    _fetchUserPosts(widget.userId);
    if(user?.admindeleted == true)
    {
      deleteProfileStatus = "Deleted profile by admin on :  ${user?.admindeletedon}";
    }
    setState(() {
      isLoading = false;
    });
  }
  Future<void> _fetchUserPosts(String userId) async {
    print("function call");
    // Get the user ID
    UserPostService userPostService = UserPostService();
    print("uuserid : $userId");

    await userPostService.getAllUserPost(userId, DataOperationCallback<List<UserPost>>(
      onSuccess: (posts) {

        //print("posts count : $count");
        setState(() {

          _postImages = posts
              .where((post) => post.uploadedImageUris?.isNotEmpty == true)
              .map((post) => PostImageData(
            postId: post.postId ?? '',
            imageUrl: post.uploadedImageUris![0],
          ))
              .toList();
          postsCount = _postImages.length;
        });
      },
      onFailure: (error) {
        // Handle error
        print("Failed to fetch posts: $error");
      },
    ));
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
    userService.adminDeleteProfile(userId, OperationCallback(
      onSuccess: () {
        setState(() {
          user?.admindeleted = true;
          deleteProfileStatus = "Deleted profile by admin on :  ${Utils.getCurrentDatetime()}";
        });
        Utils.showMessage(context, "profile deleted successfully done.");
      },
      onFailure: (errMessage) {
        Utils.showError(context, "delete profile failed! Please try again later.");
      },
    ));
  }
  void _undeleteProfile(String userId) {
    userService.adminUnDeleteProfile(userId, OperationCallback(
      onSuccess: () {
        setState(() {
          user?.admindeleted = false;
          deleteProfileStatus = "";
        });
        Utils.showMessage(context, "profile activate  successfully done.");
      },
      onFailure: (errMessage) {
        Utils.showError(context, "activate profile failed! Please try again later.");
      },
    ));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Manage User")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: (user?.profilepicture != null && user!.profilepicture.isNotEmpty)
                            ? NetworkImage(user!.profilepicture)
                            : AssetImage('assets/user.png') as ImageProvider,
                      ),
                      SizedBox(height: 5),
                      Text(
                        user?.username ?? 'Unknown User',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  ProfileStat(count: postsCount.toString(), label: 'Posts'),
                  SizedBox(width: 15),
                  ProfileStat(count: '1', label: 'Followers'),
                  SizedBox(width: 15),
                  ProfileStat(count: '2', label: 'Followings'),
                ],
              ),
              SizedBox(height: 2),
              UserDetailText(label: user?.bio ?? ''),
              UserDetailText(label: user?.email ?? ''),
              SizedBox(height: 5),
              if (user?.profiledeleted == true) ...[
                UserDetailText(
                  label: "user has deleted own profile.",
                  isVisible: true,
                  textColor: Colors.white,
                  backgroundColor: Colors.red[300]!,
                )
              ]
              else ...[
                UserDetailText(
                  label:  "Suspended profile: ${user?.suspendedreason}",
                  isVisible: user?.suspended ?? false,
                  textColor: user?.suspended == true ? Colors.white : Colors.black,
                  backgroundColor: user?.suspended == true ? Color(0xFFFF9800) : Colors.transparent,
                ),
                SizedBox(height: 5),
                UserDetailText(
                  label: deleteProfileStatus,
                  isVisible: user?.admindeleted ?? false,
                  textColor: user?.admindeleted == true ? Colors.white : Colors.black,
                  backgroundColor: user?.admindeleted == true ? Colors.red[300]! : Colors.transparent,
                ),
              ],
              if (user?.profiledeleted == false) ...[
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
                        onPressed: user?.admindeleted == true ? () => _undeleteProfile(widget.userId) : () => _deleteProfile(widget.userId),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 10),
              _postImages.isNotEmpty
                  ? Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Adjust as needed
                    childAspectRatio: 1,
                    // crossAxisSpacing: 1,
                    //mainAxisSpacing: 8,
                  ),
                  itemCount: _postImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminPostDetailScreen(postId: _postImages[index].postId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          image: DecorationImage(
                            image: NetworkImage(_postImages[index].imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
                  : SizedBox(),

            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomNavigation(currentIndex: 4, onTap: (index){

      }),
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
      padding: EdgeInsets.only(left: 10),
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

