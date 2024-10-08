import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialtrailsapp/ModelData/UserRole.dart';
import 'package:socialtrailsapp/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ModelData/Users.dart';
import 'Utility/SessionManager.dart';
import 'Utility/UserService.dart';
import 'Utility/Utils.dart';
import 'forgotpassword.dart';
import 'main.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService userService = UserService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('remember_username');
    bool? rememberMe = prefs.getBool('remember_me');

    if (rememberMe == true) {
      setState(() {
        _emailController.text = username ?? '';
        _rememberMe = true;
      });
    }
  }

  void _validateUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (_rememberMe) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('remember_username', email);
      await prefs.setBool('remember_me', true);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_username');
      await prefs.remove('remember_me');
    }

    if (email.isEmpty) {
      Utils.showError(context, "Email address is required");
      return;
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      Utils.showError(context, "Invalid email address");
      return;
    }
    if (password.isEmpty || password.length < 8) {
      Utils.showError(context, "Password must be at least 8 characters long");
      return;
    } else if (!Utils.isValidPassword(password)) {
      Utils.showError(context, "Password must contain at least one letter and one digit.");
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Check if the user is an admin
        if (email.toLowerCase() == "socialtrails2024@gmail.com") {
          // Admin logged in directly
          await SessionManager().loginUser(
           user.uid ?? "",
           "Admin" ?? "",
           "socialtrails2024@gmail.com" ?? "",
            "" ?? "",
            false,
            UserRole.admin.getRole() ?? "",
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // For regular users, check email verification
          if (user.emailVerified) {
            Users? data = await userService.getUserByID(user.uid);
            if (data != null && data.userId != null) {
              await SessionManager().loginUser(
                data.userId ?? "",
                data.username ?? "",
                data.email ?? "",
                data.bio ?? "",
                data.notification ?? true,
                data.roles ?? "",
              );

              if (data?.suspended == true) {
                Utils.showError(context, "Your account has been suspended by admin. Please contact support.");
                await _auth.signOut();
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }
            } else {
              Utils.showError(context, "Something went wrong! Please try again.");
              await _auth.signOut();
            }
          } else {
            // Ask for email verification for regular users
            Utils.showError(context, "Please verify your email before logging in.");
            await _auth.signOut();
          }
        }
      } else {
        Utils.showError(context, "Invalid email address and password");
        await _auth.signOut();
      }
    } catch (e) {
      _passwordController.clear();
      Utils.showError(context, "Invalid email address and password");
      await _auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Image.asset('assets/socialtrails_logo.png', width: 150, height: 150),
              const SizedBox(height: 20),
              Text(
                "Discover new experiences, share moments, and stay updated with the latest news from those who matter most.",
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildTextField(_emailController, "Email Address", keyboardType: TextInputType.emailAddress),
              _buildPasswordField(_passwordController, "Password", _passwordVisible, (value) {
                setState(() {
                  _passwordVisible = value;
                });
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
                      Text("Remember Me"),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordView()));
                    },
                    child: Text("Forgot password?", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Sign in", style: TextStyle(color: Colors.white)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have a profile?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                    },
                    child: Text("Create new one", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for text fields
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple, width: 2),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  // Helper method for password fields
  Widget _buildPasswordField(TextEditingController controller, String label, bool passwordVisible, Function(bool) onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.purple, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              onToggle(!passwordVisible);
            },
          ),
        ),
        obscureText: !passwordVisible,
      ),
    );
  }
}

