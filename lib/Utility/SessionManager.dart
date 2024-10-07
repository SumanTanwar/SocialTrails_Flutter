import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  SharedPreferences? _prefs;

  // Private constructor
  SessionManager._internal();

  // Factory constructor
  factory SessionManager() {
    return _instance;
  }

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ensure initialization
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  // Login user and save details
  Future<void> loginUser(String userID, String username, String email,String bio, bool notification, String roles,) async {
    await _ensureInitialized();
    await _prefs?.setString("userID", userID);
    await _prefs?.setString("username", username);
    await _prefs?.setString("email", email);
    await _prefs?.setString("bio", bio);
    await _prefs?.setBool("notification", notification);
    await _prefs?.setBool("isLoggedIn", true);
    await _prefs?.setString("roleType", roles);

  }



  // Getters for user details
  String? getUserID() {
    return _prefs?.getString("userID");
  }

  String? getUsername() {
    return _prefs?.getString("username");
  }

  String? getEmail() {
    return _prefs?.getString("email");
  }


  String? getBio() {
    return _prefs?.getString("bio");
  }



  bool getNotificationStatus() {
    return _prefs?.getBool("notification") ?? false;
  }

  String? getRoleType() {
    return _prefs?.getString("roleType");
  }

  bool isLoggedIn() {
    return _prefs?.getBool("isLoggedIn") ?? false;
  }

  // Set notification status
  Future<void> setNotificationStatus(bool notification) async {
    await _prefs?.setBool("notification", notification);
  }

  // Logout user
  // Future<void> logoutUser() async {
  //   await _prefs?.clear();
  // }

   Future<void> logoutUser() async {
     await _prefs?.remove("userID");
     await _prefs?.remove("username");
     await _prefs?.remove("email");
     await _prefs?.remove("bio");
     await _prefs?.remove("notification");
     await _prefs?.remove("roleType");
     await _prefs?.setBool("isLoggedIn", false);
   }

  // Update user information
  Future<void> updateUserInfo(String username, String email, String bio) async {
    await _ensureInitialized(); // Ensure initialization
    if (username.isNotEmpty) {
      await _prefs?.setString("username", username);
    }
    if (email.isNotEmpty) {
      await _prefs?.setString("email", email);
    }
    if (bio.isNotEmpty) {
      await _prefs?.setString("bio", bio);
    }
  }
}