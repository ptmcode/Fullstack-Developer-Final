import 'package:flutter/material.dart';
import 'package:simple_state_management_app/screens/auth/forgot_password_screen.dart';
import 'package:simple_state_management_app/screens/auth/register_screen.dart';
import 'package:simple_state_management_app/screens/home/home_screen.dart';
import 'package:simple_state_management_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var phoneNumberController = TextEditingController();
  var passwordController = TextEditingController();
  var authService = AuthService();
  bool isLoading = false;

  _onLogin() async {
    if (phoneNumberController.text.isEmpty || passwordController.text.isEmpty) {
      _showMessage("Please enter phone number and password", isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    var res = await authService.login(
      phoneNumberController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });
    if (!mounted) return;

    if (res.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      _showMessage(res.message ?? "Login failed", isError: true);
    }
  }

  _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            Icon(Icons.lock_outline, size: 80, color: Colors.cyan),
            SizedBox(height: 10),
            Text(
              "Welcome Back",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(hint: Text("Phone number")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(hint: Text("Password")),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  "Forgot password?",
                  style: TextStyle(color: Colors.cyan),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (!isLoading) {
                  _onLogin();
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 15, bottom: 20),
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Login", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text("Register", style: TextStyle(color: Colors.cyan)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
