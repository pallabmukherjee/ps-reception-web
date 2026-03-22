import 'package:flutter/material.dart';
import 'package:kp_police/controllers/auth_service.dart';
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
  int _selectedIndex = 0; // Track the selected index for BottomNavigationBar
  String _userName = ''; // Store the user's name
  bool _isProfileComplete = true; // Flag to track profile completeness

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user name when the page loads
    PushNotifications.getDeviceToken();  // For push notifications
  }

  // Function to fetch the user's name from SharedPreferences
  Future<void> _fetchUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userName = prefs.getString('user_name') ?? '';

      if (userName.isEmpty) {
        setState(() {
          _isProfileComplete = false; 
        });
      } else {
        setState(() {
          _userName = userName;
          _isProfileComplete = true; 
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: $e')),
      );
    }
  }

  // Update the selected index when a tab is selected
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Home", showBackButton: false),
      drawer: CustomDrawer(),
      body: Container(
        height: double.infinity, // Ensures the container takes the full height of the screen
        decoration: BoxDecoration(
          color: Color(0xFFFAF9F6), // Full background color
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,  // This ensures the Column doesn't take more space than needed
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Krishnanagar ',
                      style: TextStyle(
                        color: Color(0xFFFF0000), // Red color for "Krishnanagar"
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'PD',
                      style: TextStyle(
                        color: Color(0xFF00137F), // Blue color for "PD"
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Reception Management',
                style: TextStyle(
                  color: Color(0xFF57007F), // Purple color for "Reception Management"
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 40),
              // Conditionally display the welcome message or the incomplete profile message
              Center(
                child: _isProfileComplete
                    ? Text(
                  'Welcome, $_userName', // Display the fetched user name here
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                )
                    : Column(
                  children: [
                    Text(
                      'Your profile is not complete. Please complete your profile.',
                      textAlign: TextAlign.center,  // Ensures text is centered
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFdf0100),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ElevatedButton(
              //   onPressed: _navigateToReportPage,
              //   child: Text(
              //     "Go to Report Page",
              //     style: TextStyle(
              //       fontSize: 18,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SuperiorCustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
