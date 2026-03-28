import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  CustomAppBar({required this.title, this.showBackButton = false, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF00137F),
      centerTitle: true,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: onBackPressed ?? () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? role = prefs.getString('user_role');
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  if (role == 'superior') {
                    Navigator.pushReplacementNamed(context, '/superiorhome');
                  } else {
                    Navigator.pushReplacementNamed(context, '/adminhome');
                  }
                }
              },
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 28),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
