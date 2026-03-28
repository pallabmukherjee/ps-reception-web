import 'package:flutter/material.dart';
import 'package:kp_police/controllers/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _userName = 'Official User';
  String _userRole = 'Personnel';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Official User';
      _userRole = prefs.getString('user_role')?.toUpperCase() ?? 'PERSONNEL';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () => Navigator.pushReplacementNamed(context, _userRole == 'SUPERIOR' ? '/superiorhome' : '/adminhome'),
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_rounded,
                  title: 'Case Records',
                  onTap: () => Navigator.pushNamed(context, _userRole == 'SUPERIOR' ? '/superior-list-complaint' : '/list_complaint'),
                ),
                _buildDrawerItem(
                  icon: Icons.add_moderator_rounded,
                  title: 'Register New Case',
                  onTap: () => Navigator.pushNamed(context, '/add_complaint'),
                ),
                const Divider(indent: 20, endIndent: 20, height: 32),
                _buildDrawerItem(
                  icon: Icons.account_circle_rounded,
                  title: 'Official Profile',
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _buildDrawerItem(
                  icon: Icons.security_rounded,
                  title: 'Security Settings',
                  onTap: () => Navigator.pushNamed(context, '/change_password'),
                ),
              ],
            ),
          ),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF00137F),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF00137F),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _userRole,
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00137F), size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      visualDensity: const VisualDensity(vertical: -1),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: InkWell(
        onTap: () async {
          await AuthService.logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF0000).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFFF0000), size: 20),
              SizedBox(width: 12),
              Text(
                "SIGN OUT",
                style: TextStyle(color: Color(0xFFFF0000), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
