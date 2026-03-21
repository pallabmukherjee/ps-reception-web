import 'package:flutter/material.dart';
import 'package:kp_police/controllers/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  CustomAppBar({required this.title, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFF1251a0),
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
        icon: Icon(
          Icons.arrow_back,  // Back arrow icon
          color: Colors.white, // Set icon color to white
          size: 25, // Set icon size to 25
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      )
          : null,
      actions: [
        IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Open the Drawer when clicked
          },
        ),
      ],

    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Default AppBar height
}