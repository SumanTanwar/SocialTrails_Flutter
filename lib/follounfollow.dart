import 'package:flutter/material.dart';
import 'package:socialtrailsapp/Interface/OperationCallback.dart';
import 'package:socialtrailsapp/ModelData/Report.dart';
import 'package:socialtrailsapp/Utility/FollowService.dart';
import 'package:socialtrailsapp/Utility/ReportService.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/Utility/UserService.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';
import 'package:socialtrailsapp/main.dart';
import '../Interface/DataOperationCallback.dart';
import '../ModelData/UserPost.dart';
import '../Utility/UserPostService.dart';
import '../Utility/Utils.dart';

class FollowUnfollowView extends StatefulWidget {
  final String userId;


  FollowUnfollowView({required this.userId});

  @override
  _FollowUnfollowViewState createState() => _FollowUnfollowViewState();
}

class _FollowUnfollowViewState extends State<FollowUnfollowView> {
  Users? user;


  bool isLoading = true;
  bool isFollowing = false;
  bool isPendingRequest = false;
  bool isFollowUnFollow = true;
  bool isFollowedBack = false;
  bool showConfirmationButtons = false;
  String alertMessage = '';
  bool showingAlert = false;

  String currentUserId = SessionManager().getUserID()!;
  final UserService userService = UserService();
  final UserPostService userPostService = UserPostService();
  final FollowService followService = FollowService();



  void sendFollowRequest() {
    setState(() {
      isPendingRequest = true;
      isFollowing = true;
      isFollowUnFollow = false;
    });

    // Call the sendFollowRequest method
    followService.sendFollowRequest(currentUserId, widget.userId).then((_) {
      // If the function completes successfully
      setState(() {
        alertMessage = "Follow request sent!";
        showingAlert = true;
        isFollowUnFollow = false; // Change button to unfollow after request is sent
      });
    }).catchError((error) {
      // Handle the error
      setState(() {
        alertMessage = "Error sending follow request: $error";
        showingAlert = true;
      });
    });
  }

  Future<void> _checkPendingRequest() async {
    bool hasPendingRequest = await followService.checkPendingRequestsForCancel(currentUserId, widget.userId);
    setState(() {
      isPendingRequest = hasPendingRequest;
      isFollowUnFollow = !isPendingRequest;  // If there's a pending request, we shouldn't show the "Follow" button
    });
  }

  void unfollowUser() {
    setState(() {
      isFollowing = false;
    });
  }

  void cancelFollowRequest() {
    setState(() {
      isPendingRequest = false;
      isFollowUnFollow = true;
    });

    // Call the cancelFollowRequest method
    followService.cancelFollowRequest(currentUserId, widget.userId).then((_) {
      // If the function completes successfully
   //   followService.sendNotify(widget.userId, 'has cancelled the follow request', currentUserId);

      setState(() {
        alertMessage = "Follow request canceled!";
        showingAlert = true;
        isFollowUnFollow = true;  // Change button back to "Follow"
      });
    }).catchError((error) {
      // Handle the error
      setState(() {
        alertMessage = "Error canceling follow request: $error";
        showingAlert = true;
      });
    });
  }

  void confirmFollowRequest() {
    setState(() {
      isPendingRequest = false;
      isFollowing = true;
    });
  }

  void rejectFollowRequest() {
    setState(() {
      isPendingRequest = false;
    });
  }

  void followBack() {
    setState(() {
      isFollowedBack = false;
      isFollowing = true;
    });
  }


  List<String> _postImages = [];
  int postsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _checkPendingRequest();
  }

  Future<void> _fetchUserDetails() async {
    user = await userService.adminGetUserByID(widget.userId);
    _fetchUserPosts(widget.userId);
    setState(() {
      isLoading = false;
    });
  }



  Future<void> _fetchUserPosts(String userId) async {
    await userPostService.getAllUserPost(userId, DataOperationCallback<List<UserPost>>(
      onSuccess: (posts) {
        setState(() {
          _postImages = posts
              .map((post) => (post.uploadedImageUris?.isNotEmpty == true)
              ? post.uploadedImageUris![0]
              : null)
              .where((image) => image != null)
              .cast<String>()
              .toList();

          postsCount = _postImages.length;
        });
      },
      onFailure: (error) {
        print("Failed to fetch posts: $error");
      },
    ));
  }

  void openReportDialog(BuildContext context, String userId) {
    String reason = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0),
          title: Text(
            'Report User',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Why are you reporting this user?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'Your report is anonymous. If someone is in immediate danger, call the local emergency service.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 8),
              TextField(
                maxLines: 5,
                onChanged: (value) {
                  reason = value;
                },
                decoration: InputDecoration(
                  hintText: 'Describe the issue here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(8.0),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (reason.isNotEmpty) {
                  reportUser(userId, reason);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please provide a reason for reporting.')),
                  );
                }
              },
              child: Text('Report'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void reportUser(String userId, String reason) {
    Report report = Report(
      createdon: DateTime.now().toString(),
      reason: reason,
      reportedid: userId,
      reporterid: SessionManager().getUserID()!,
      reporttype: 'user',
      status: 'pending',
    );

    ReportService reportService = ReportService();

    reportService.addReport(
      report,
      OperationCallback(
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report submitted successfully!')),
          );
        },
        onFailure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Something went wrong! Please try again later.')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('User Profile'),),
    body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: const EdgeInsets.only(top:5.0),
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
                  ProfileStat(count: postsCount.toString(), label: 'Posts'), // Updated to show actual post count
                  SizedBox(width: 15),
                  ProfileStat(count: '0', label: 'Followers'), // Placeholder for followers count
                  SizedBox(width: 15),
                  ProfileStat(count: '0', label: 'Followings'), // Placeholder for followings count
                ],
              ),
              UserDetailText(label: user?.bio ?? '', onReportPressed: () => openReportDialog(context, user!.userId)),
            //  SizedBox(height: 5),

              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    // Follow/Unfollow button with your provided style
                    if (!isPendingRequest) // Show follow/unfollow only if no pending request
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isFollowing ? unfollowUser : sendFollowRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple, // Button color
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: Text(
                              isFollowing ? 'Unfollow' : 'Follow',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                    // Cancel Request button
                    if (isPendingRequest) // Show cancel request only if there's a pending request
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: cancelFollowRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: Text(
                              "Cancel Request",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              _postImages.isNotEmpty
                  ? Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                  ),
                  itemCount: _postImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        image: DecorationImage(
                          image: NetworkImage(_postImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              )
                  : Text("No posts available"),
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
  final VoidCallback onReportPressed; // Callback for reporting

  UserDetailText({required this.label, required this.onReportPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          IconButton(
            icon: Icon(Icons.warning), // Icon for reporting
            onPressed: onReportPressed,
          ),
        ],
      ),
    );

  }
}

