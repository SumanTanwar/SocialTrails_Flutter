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
import 'ModelData/Notification.dart';
import 'Utility/NotificationService.dart';

class FollowUnfollowView extends StatefulWidget {

  final String userIdToFollow;

  FollowUnfollowView({ required this.userIdToFollow});


  @override
  _FollowUnfollowViewState createState() => _FollowUnfollowViewState();
}

class _FollowUnfollowViewState extends State<FollowUnfollowView> {

  Users? user;


  bool isLoading = true;
  bool isFollowing = false;
  bool isPendingRequest = false;
  bool isFollowUnFollow = false;
  bool isFollowedBack = false;
  bool showConfirmationButtons = false;

  String alertMessage = '';
  bool showingAlert = false;
  List<String> _postImages = [];
  int postsCount = 0;



  final UserService userService = UserService();
  final UserPostService userPostService = UserPostService();
  final FollowService followService = FollowService();

  final currentUserId = SessionManager().getUserID() ?? "" ;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    user = await userService.adminGetUserByID(widget.userIdToFollow);
    _fetchUserPosts(widget.userIdToFollow);
    _checkPendingRequestsForCancel(widget.userIdToFollow);
    setState(() {
      isLoading = false;
    });
  }


  Future<void> _checkPendingRequestsForCancel(String userIdToCheck) async {

    try {
      bool isPending = await followService.checkPendingRequestsForCancel(currentUserId, userIdToCheck);
      setState(() {
        isPendingRequest = isPending;
        isFollowUnFollow = false;
      });

      if (!isPending) {
        _checkPendingforFollowingUser(userIdToCheck);

      }
    } catch (error) {
      setState(() {
        isPendingRequest = false;
      });
      print("cancel request false");
      _checkPendingforFollowingUser(userIdToCheck);
    }
  }

  Future<void> _checkPendingforFollowingUser(String userIdToCheck) async {
    try {

      bool isPending = await followService.checkPendingForFollowingUser(currentUserId, userIdToCheck);

      setState(() {
        showConfirmationButtons = isPending;
        isFollowUnFollow = false;
      });


      if (!isPending) {
        _checkFollowBack(userIdToCheck);
      } else {

        print("has pending follow request, not checking follow back");
      }
    } catch (error) {

      setState(() {
        showConfirmationButtons = false;
      });
      print("Error checking pending follow: $error");


      _checkFollowBack(userIdToCheck);
    }
  }




  void _checkFollowBack(String userIdToCheck) async {
      String currentUserId = this.currentUserId;

      try {
        bool isFollowing = await followService.checkIfFollowed(currentUserId,widget.userIdToFollow);

        print("is following : $isFollowing" );
        if (isFollowing) {
          setState(() {
            this.isFollowedBack = true;
          });

          bool isFollowedBack = await followService.checkIfFollowed(widget.userIdToFollow,currentUserId);
          print("is followed back : $isFollowedBack" );
          if (isFollowedBack) {
            setState(() {
              this.isFollowedBack = false;
            });
            updateUIForUnfollowButton();
          }
        } else {

          bool isFollowedBack = await followService.checkIfFollowed(widget.userIdToFollow,currentUserId);
          print("in esel is following : $isFollowedBack" );
          if (isFollowedBack) {
            updateUIForUnfollowButton();
          } else {
            showFollowButton();
          }
        }
      } catch (e) {
        showFollowButton();
      }
    }


  Future<void> sendFollowRequest() async {
    try {
      await followService.sendFollowRequest(currentUserId, widget.userIdToFollow);

      setState(() {
        isFollowUnFollow = false;
        isPendingRequest = true;
      });

      _sendNotifications( widget.userIdToFollow, " has sent a follow request to you", currentUserId);
      alertMessage = "Follow request sent!";
      showingAlert = true;
    } catch (error) {
      setState(() {
        alertMessage = "Error sending follow request: $error";
        showingAlert = true;
      });
    }
  }



  Future<void> cancelFollowRequest() async {
    try {
      await followService.cancelFollowRequest(
          currentUserId,
          widget.userIdToFollow);

      setState(() {
        isPendingRequest = false;
      });
      showFollowButton();


      _sendNotifications(widget.userIdToFollow, " has canceled the follow request", currentUserId);
      alertMessage = "Follow request canceled!";
      showingAlert = true;
    } catch (error) {
      setState(() {
        isPendingRequest = true;
        isFollowUnFollow = false;
        alertMessage = "Error canceling follow request: $error";
        showingAlert = true;
      });
    }
  }


  void _confirmFollowRequest() async {
    try {
      // Use positional arguments instead of named
      await followService.confirmFollowRequest(
        currentUserId,
        widget.userIdToFollow,
      );

      setState(() {

        showConfirmationButtons = false;
        isFollowedBack = true;
        showingAlert = true;
        alertMessage = "Follow request confirmed!";
      });
      _sendNotifications(widget.userIdToFollow,'has started following you',currentUserId);

    } catch (error) {
      setState(() {
        alertMessage = "Error: ${error.toString()}";
        showingAlert = true;
      });
    }
  }


  void _rejectFollowRequest() async {
    try {

      await followService.rejectFollowRequest(
        currentUserId: currentUserId,
        userIdToFollow: widget.userIdToFollow,
      );


      setState(() {
        alertMessage = "Follow request rejected!";
        isPendingRequest = false;       // Set pending status to false (no longer pending)
        showConfirmationButtons = false;

      });
      _sendNotifications(widget.userIdToFollow,'has rejected your follow request',currentUserId);

      showFollowButton();
    } catch (error) {

      setState(() {
        alertMessage = "Error: ${error.toString()}";
        showingAlert = true;
      });
    }
  }


  Future<void> unfollowUser() async {
    try {
      // Call unfollowUser service to unfollow the user
      await followService.unfollowUser(
          currentUserId: currentUserId,
          userIdToUnfollow: widget.userIdToFollow
      );


      alertMessage = "You have successfully unfollowed the user";
      showingAlert = true;
      showFollowButton();
      _sendNotifications(widget.userIdToFollow,'has unfollowed you',currentUserId);
      // sendNotify(notifyTo: widget.userIdToFollow, text: " has unfollowed you", notifyBy: currentUserId);

    } catch (error) {
      // Show error message if something goes wrong
      alertMessage = "Error: ${error.toString()}";
      showingAlert = true;
    }
  }



  void _followBack() async {
      try {
        await followService.confirmFollowBack(currentUserId: currentUserId, userIdToFollow:widget.userIdToFollow);

        setState(() {
          isFollowedBack = false;
        });
        alertMessage = "You are now following this user!";
        showingAlert = true;

        updateUIForUnfollowButton();
        _sendNotifications(widget.userIdToFollow,'has started following you',currentUserId);
     //   sendNotify(notifyTo: userId, text: " has started following you", notifyBy: currentUserId);
      } catch (error) {

      }
    }



    void updateUIForUnfollowButton() {
    setState(() {
      isFollowUnFollow = true;
      isFollowing = true;
    });
  }


  void showFollowButton() {
    setState(() {
      isFollowUnFollow = true;
      isFollowing = false;
    });
  }

  Future<void> _sendNotifications(String notifyTo,String text,String notifyBy) async {
    NotificationModal notification = NotificationModal(
      notifyto: notifyTo,
      notifyBy: notifyBy,
      type: "follow",
      message: text,
      relatedId: notifyBy,
    );
    await NotificationService().sendNotificationToUser(notification);
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

                    // Follow/Unfollow button
                    if (isFollowUnFollow)
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (isFollowing) {
                                unfollowUser();
                              } else {
                                sendFollowRequest();
                              }
                            },
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
                    if (isPendingRequest)
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              cancelFollowRequest();
                            },
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

                    // Show confirm/reject buttons if there's a pending request
                    if (showConfirmationButtons)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // First Button - Confirm
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _confirmFollowRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                child: Text(
                                  'Confirm',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(width: 5), // Space between the buttons
                            // Second Button - Reject
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _rejectFollowRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                child: Text(
                                  'Reject',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),


                    // Follow Back button
                    if (isFollowedBack)
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _followBack,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              backgroundColor: Colors.purple,
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: Text(
                              'Follow Back',
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

