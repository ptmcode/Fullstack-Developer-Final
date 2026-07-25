import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/user.dart';
import 'package:simple_state_management_app/services/admin_user_service.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  var usernameController = TextEditingController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var adminUserService = AdminUserService();
  bool isLoading = false;

  @override
  void initState() {
    var user = widget.user;
    if (user != null) {
      usernameController.text = user.username ?? "";
      firstNameController.text = user.firstName ?? "";
      lastNameController.text = user.lastName ?? "";
      emailController.text = user.email ?? "";
      phoneNumberController.text = user.phoneNumber ?? "";
    }
    super.initState();
  }

  _onSave() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showMessage("Password and confirm password do not match", isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    var body = <String, dynamic>{
      "username": usernameController.text,
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "email": emailController.text,
      "phoneNumber": phoneNumberController.text,
      "password": passwordController.text,
      "confirmPassword": confirmPasswordController.text,
      "role": "USER",
      "profile": widget.user?.profile ?? "",
    };
    if (widget.user != null) {
      body["id"] = widget.user!.id!;
      body["status"] = widget.user!.status ?? "ACT";
    }
    var res = widget.user == null
        ? await adminUserService.createUser(body)
        : await adminUserService.updateUser(body);

    setState(() {
      isLoading = false;
    });
    if (!mounted) return;

    if (res.isSuccess) {
      Navigator.pop(context, true);
    } else {
      _showMessage(res.message ?? "Save failed", isError: true);
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
        title: Text(
          widget.user == null ? "Create User" : "Update User",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 35),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(hint: Text("Username")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(hint: Text("First name")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(hint: Text("Last name")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hint: Text("Email")),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(hint: Text("Confirm password")),
            ),
            GestureDetector(
              onTap: () {
                if (!isLoading) {
                  _onSave();
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
                          widget.user == null ? "Create" : "Update",
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
