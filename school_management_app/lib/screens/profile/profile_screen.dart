import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_state_management_app/models/user.dart';
import 'package:simple_state_management_app/services/auth_service.dart';
import 'package:simple_state_management_app/services/session.dart';
import 'package:simple_state_management_app/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var usernameController = TextEditingController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var userService = UserService();
  var authService = AuthService();
  bool isLoading = false;
  File? profileImage;

  @override
  void initState() {
    var user = Session.currentUser;
    if (user != null) {
      usernameController.text = user.username ?? "";
      firstNameController.text = user.firstName ?? "";
      lastNameController.text = user.lastName ?? "";
      emailController.text = user.email ?? "";
      phoneNumberController.text = user.phoneNumber ?? "";
    }
    super.initState();
  }

  _onPickImage() async {
    var picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      profileImage = File(picked.path);
    });

    var res = await authService.uploadProfileImage(File(picked.path));
    if (!mounted) return;
    if (res.isSuccess) {
      _showMessage(res.message ?? "Image uploaded successfully!");
    } else {
      _showMessage(res.message ?? "Upload failed", isError: true);
    }
  }

  _onSave() async {
    setState(() {
      isLoading = true;
    });

    var user = User(
      id: Session.currentUser?.id,
      username: usernameController.text,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phoneNumber: phoneNumberController.text,
    );
    var res = await userService.updateProfile(user);

    setState(() {
      isLoading = false;
    });
    if (!mounted) return;

    if (res.isSuccess) {
      Session.currentUser?.username = user.username;
      Session.currentUser?.firstName = user.firstName;
      Session.currentUser?.lastName = user.lastName;
      Session.currentUser?.email = user.email;
      Session.currentUser?.phoneNumber = user.phoneNumber;
      _showMessage(res.message ?? "Profile updated successfully!");
    } else {
      _showMessage(res.message ?? "Update failed", isError: true);
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
        title: Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 35),
        child: Column(
          children: [
            GestureDetector(
              onTap: _onPickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.cyan.shade50,
                backgroundImage:
                    profileImage == null ? null : FileImage(profileImage!),
                child: profileImage == null
                    ? Icon(Icons.add_a_photo, size: 35, color: Colors.cyan)
                    : null,
              ),
            ),
            SizedBox(height: 30),
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
                      : Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
