import 'package:flutter/material.dart';
import 'package:kp_police/controllers/auth_service.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF1251a0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,  // Align text to the left
              children: [
                SizedBox(height: 20),
                Text(
                  'West Bengal Police',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),  // Add some space between the two texts
                Text(
                  'Reception Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,  // You can adjust the size as needed
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              // Navigate to Profile screen
              Navigator.pushNamed(context, "/profile");
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: () {
              // Navigate to Change Password screen
              Navigator.pushNamed(context, "/change_password");
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await AuthService.logout(); // Logout functionality
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}
