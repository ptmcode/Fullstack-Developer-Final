import 'package:flutter/material.dart';
import 'package:simple_state_management_app/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  var phoneNumberController = TextEditingController();
  var otpController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var authService = AuthService();
  bool isLoading = false;
  // 0 = enter phone, 1 = verify OTP, 2 = set new password
  int step = 0;

  _onNext() async {
    setState(() {
      isLoading = true;
    });

    var res = switch (step) {
      0 => await authService.forgotPasswordSendOtp(phoneNumberController.text),
      1 => await authService.forgotPasswordVerifyOtp(
          phoneNumberController.text, otpController.text),
      _ => await authService.forgotPasswordFinish(
          phoneNumberController.text,
          otpController.text,
          passwordController.text,
          confirmPasswordController.text),
    };

    setState(() {
      isLoading = false;
    });
    if (!mounted) return;

    if (res.isSuccess) {
      if (step < 2) {
        setState(() {
          step++;
        });
      } else {
        _showMessage(res.message ?? "Password changed successfully!");
        Navigator.pop(context);
        return;
      }
      _showMessage(res.message ?? "Success");
    } else {
      _showMessage(res.message ?? "Request failed", isError: true);
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
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Forgot Password", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 35),
        child: Column(
          children: [
            Text(
              switch (step) {
                0 => "Enter your phone number to receive an OTP code",
                1 => "Enter the OTP code sent to your phone",
                _ => "Set your new password",
              },
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            TextField(
              controller: phoneNumberController,
              enabled: step == 0,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(hint: Text("Phone number")),
            ),
            if (step >= 1) ...[
              SizedBox(height: 20),
              TextField(
                controller: otpController,
                enabled: step == 1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hint: Text("OTP code")),
              ),
            ],
            if (step == 2) ...[
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(hint: Text("New password")),
              ),
              SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(hint: Text("Confirm new password")),
              ),
            ],
            GestureDetector(
              onTap: () {
                if (!isLoading) {
                  _onNext();
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 35),
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
                      : Text(
                          switch (step) {
                            0 => "Send OTP",
                            1 => "Verify OTP",
                            _ => "Change Password",
                          },
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
