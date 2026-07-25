import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/user.dart';
import 'package:simple_state_management_app/screens/user/user_form_screen.dart';
import 'package:simple_state_management_app/services/admin_user_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  var adminUserService = AdminUserService();
  List<User> userList = [];
  bool isLoading = false;

  @override
  void initState() {
    _getAllUsers();
    super.initState();
  }

  _getAllUsers() async {
    setState(() {
      isLoading = true;
      userList = [];
    });

    var res = await adminUserService.getUsers();

    setState(() {
      isLoading = false;
      if (res.isSuccess) {
        userList = User.listFromJson(res.data);
      }
    });
    if (!res.isSuccess && mounted) {
      _showMessage(res.message ?? "Can not load users", isError: true);
    }
  }

  _onDelete(User user) async {
    var res = await adminUserService.deleteUser(user.id!);
    if (!mounted) return;
    if (res.isSuccess) {
      _showMessage(res.message ?? "User deleted successfully!");
      _getAllUsers();
    } else {
      _showMessage(res.message ?? "Delete failed", isError: true);
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
        title: Text("Users", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserFormScreen()),
              ).then((onValue) {
                if (onValue == true) {
                  _getAllUsers();
                }
              });
            },
            icon: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.cyan))
          : RefreshIndicator(
              onRefresh: () async {
                _getAllUsers();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  var user = userList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserFormScreen(user: user),
                          ),
                        ).then((onValue) {
                          if (onValue == true) {
                            _getAllUsers();
                          }
                        });
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.cyan.shade50,
                        child: Icon(Icons.person, color: Colors.cyan),
                      ),
                      title: Text(user.fullName),
                      subtitle: Text(
                        "${user.username} • ${user.phoneNumber} • ${user.isAdmin ? "ADMIN" : "USER"}",
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          _onDelete(user);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
