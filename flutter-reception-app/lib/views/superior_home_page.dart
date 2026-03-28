import 'package:flutter/material.dart';
import 'package:kp_police/controllers/auth_service.dart';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:kp_police/controllers/notification_polling_service.dart';
import 'package:kp_police/controllers/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'layout/app_bar.dart';
import 'layout/custom_drawer.dart';
import 'layout/superior_custom_bottom_nav.dart';


class SuperiorHomePage extends StatefulWidget {
  const SuperiorHomePage({super.key});

  @override
  State<SuperiorHomePage> createState() => _SuperiorHomePageState();
}

class _SuperiorHomePageState extends State<SuperiorHomePage> {
  int _selectedIndex = 0;
  String _userName = '';
  bool _isProfileComplete = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userName = prefs.getString('user_name') ?? '';
      setState(() {
        _userName = userName;
        _isProfileComplete = userName.isNotEmpty;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Superior Panel", showBackButton: false),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "COMMAND CENTER",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildPremiumCard(
                        context,
                        title: "Live Reports",
                        subtitle: "Track all cases",
                        icon: Icons.analytics_outlined,
                        color: const Color(0xFF00137F),
                        onTap: () => Navigator.pushNamed(context, '/superior-list-complaint'),
                      ),
                      _buildPremiumCard(
                        context,
                        title: "Statistics",
                        subtitle: "Data insights",
                        icon: Icons.bar_chart_rounded,
                        color: const Color(0xFFFF0000),
                        onTap: () => Navigator.pushNamed(context, '/superior-statistics'),
                      ),
                      _buildPremiumCard(
                        context,
                        title: "Police Profile",
                        subtitle: "Official details",
                        icon: Icons.admin_panel_settings_outlined,
                        color: Colors.green,
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                      _buildPremiumCard(
                        context,
                        title: "Security",
                        subtitle: "Change access",
                        icon: Icons.lock_reset_rounded,
                        color: Colors.blueGrey,
                        onTap: () => Navigator.pushNamed(context, '/change_password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SuperiorCustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00137F), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'West Bengal ',
                  style: TextStyle(
                    color: Color(0xFFFF0000),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: 'Police',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'OFFICER IN-CHARGE PANEL',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF00137F),
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'O',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isProfileComplete ? 'Welcome, $_userName' : 'Official Profile',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Assigned Station Commander',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              subtitle.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
