import 'package:flutter/material.dart';
import 'package:socialtrailsapp/ModelData/Users.dart';
import 'package:socialtrailsapp/Utility/IssueWarningService.dart';
import 'package:socialtrailsapp/Utility/ReportService.dart';
import 'package:socialtrailsapp/Utility/SessionManager.dart';
import 'package:socialtrailsapp/signin.dart';
import '../Interface/DataOperationCallback.dart';
import '../Utility/UserPostService.dart';
import '../Utility/UserService.dart';
import '../ModelData/UserPost.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool isLoggedOut = false;
  String numberOfUsers = "0";
  String numberOfPosts = "0";
  String numberOfReports = "0";
  String numberOfWarnings = "0";
  String userRole = "";
  bool isLoading = true;


  final UserPostService userPostService = UserPostService();
  final UserService userService = UserService();
  final ReportService reportService = ReportService();
  final IssueWarningService issueWarningService = IssueWarningService();

  @override
  void initState() {
    super.initState();
    fetchUserRole();

    getRegularUserList();
    getAllUserPost();
    fetchTotalReports();
    fetchTotalWarnings();
  }

  Future<void> fetchUserRole() async {
    String? userId = SessionManager().getUserID();
    if (userId != null) {
      try {
        final user = await userService.getUserByID(userId);
        setState(() {
          userRole = (user?.roles ?? 'admin').toUpperCase();
          isLoading = false;
        });
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user role: $error')),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SigninScreen()),
      );
    }
  }

  Future<void> getRegularUserList() async {
    try {
      List<Users> userList = await userService.getRegularUserList();
      setState(() {
        numberOfUsers = userList.length.toString();
      });
    } catch (error) {
      setState(() {
        numberOfUsers = "0";
      });
      print("Error fetching user list: $error");
    }
  }

  void getAllUserPost() {
    userPostService.getPostCount(DataOperationCallback<int>(
      onSuccess: (count) {
        setState(() {
          numberOfPosts = count.toString();
        });
      },
      onFailure: (error) {
        setState(() {
          numberOfPosts = "0";
        });
        print("Error fetching posts count: $error");
      },
    ));
  }


  Future<void> fetchTotalReports() async {
    reportService.getReportCount(DataOperationCallback<int>(onSuccess: (count) {
      setState(() {
        numberOfReports = count.toString();
      });
    }, onFailure: (error) {
      setState(() {
        numberOfReports = "0";
      });
      print("Error fetching report count: $error");
    }));
  }

  Future<void> fetchTotalWarnings() async {
    try {
      int warningCount = await issueWarningService.fetchWarningCount();  // Assuming fetchWarningCount is in WarningService
      setState(() {
        numberOfWarnings = warningCount.toString();
      });
    } catch (error) {
      setState(() {
        numberOfWarnings = "0";
      });
      print("Error fetching warning count: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.grey[200],
              child: Text(
                userRole,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MetricSection(title: "Number of Users", value: numberOfUsers, imageName: Icons.person),
                MetricSection(title: "Number of Posts", value: numberOfPosts, imageName: Icons.post_add),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MetricSection(title: "Number of Reports", value: numberOfReports, imageName: Icons.report),
                MetricSection(title: "Number of Warnings", value: numberOfWarnings, imageName: Icons.warning),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Leverage these metrics to make data-driven decisions, optimize your operations, and enhance user experience. Your admin dashboard is your central hub for overseeing platform performance and ensuring a smooth and efficient management process.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            Image.asset("assets/socialtrails_logo.png", width: 150, height: 150), // Ensure the image is in your assets folder
            SizedBox(height: 10),
            Text(
              "SocialTrails",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MetricSection extends StatelessWidget {
  final String title;
  final String value;
  final IconData imageName;

  const MetricSection({required this.title, required this.value, required this.imageName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(imageName, size: 30),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminDashboardScreen(),
  ));
}
