import 'package:flutter/material.dart';
import 'package:simple_state_management_app/screens/auth/login_screen.dart';
import 'package:simple_state_management_app/screens/hotel/hotel_category_screen.dart';
import 'package:simple_state_management_app/screens/hotel/hotel_screen.dart';
import 'package:simple_state_management_app/screens/post/post_category_screen.dart';
import 'package:simple_state_management_app/screens/post/post_screen.dart';
import 'package:simple_state_management_app/screens/product/product_category_screen.dart';
import 'package:simple_state_management_app/screens/product/product_screen.dart';
import 'package:simple_state_management_app/screens/profile/change_password_screen.dart';
import 'package:simple_state_management_app/screens/profile/profile_screen.dart';
import 'package:simple_state_management_app/screens/user/user_screen.dart';
import 'package:simple_state_management_app/services/auth_service.dart';
import 'package:simple_state_management_app/services/session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var authService = AuthService();

  _onLogout() async {
    await authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    var user = Session.currentUser;
    var menus = [
      ("Posts", Icons.article, () => _openScreen(PostScreen())),
      ("Post Categories", Icons.category, () => _openScreen(PostCategoryScreen())),
      ("Hotels", Icons.hotel, () => _openScreen(HotelScreen())),
      ("Hotel Categories", Icons.holiday_village, () => _openScreen(HotelCategoryScreen())),
      ("Products", Icons.shopping_bag, () => _openScreen(ProductScreen())),
      ("Product Categories", Icons.sell, () => _openScreen(ProductCategoryScreen())),
      ("Users", Icons.group, () => _openScreen(UserScreen())),
      ("Profile", Icons.person, () => _openScreen(ProfileScreen())),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _onLogout,
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.cyan),
              accountName: Text(user?.fullName ?? ""),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.cyan),
              ),
            ),
            for (var (title, icon, onTap) in menus)
              ListTile(
                leading: Icon(icon, color: Colors.cyan),
                title: Text(title),
                onTap: () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
            Divider(),
            ListTile(
              leading: Icon(Icons.password, color: Colors.cyan),
              title: Text("Change Password"),
              onTap: () {
                Navigator.pop(context);
                _openScreen(ChangePasswordScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout"),
              onTap: _onLogout,
            ),
          ],
        ),
      ),
      body: GridView.count(
        padding: EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          for (var (title, icon, onTap) in menus)
            GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.cyan.shade50,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 45, color: Colors.cyan),
                    SizedBox(height: 10),
                    Text(title, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
