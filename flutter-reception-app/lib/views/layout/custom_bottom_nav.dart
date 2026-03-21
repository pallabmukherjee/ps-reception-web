import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int selectedIndex;

  CustomBottomNavigationBar({required this.onTabSelected, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) async {
        // Handle tab selection and navigate to appropriate route
        onTabSelected(index);
        switch (index) {
          case 0: // Home
            Navigator.pushReplacementNamed(context, '/adminhome');
            break;
          case 1: // Add Complaint
          // Check if receptionist data is stored in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? receptionistName = prefs.getString('receptionist_name');
            String? receptionistMobile = prefs.getString('receptionist_mobile');

            if (receptionistName != null && receptionistMobile != null) {
              // Both values are present, navigate to Add Complaint
              Navigator.pushReplacementNamed(context, '/add_complaint');
            } else {
              // One or both values are missing, navigate to the Receptionist Form
              Navigator.pushReplacementNamed(context, '/receptionist');
            }
            break;
          case 2: // List Complaint
            Navigator.pushReplacementNamed(context, '/list_complaint');
            break;
          case 3: // Complaint Detail
            Navigator.pushReplacementNamed(context, '/complaint_detail');
            break;
        }
      },
      selectedItemColor: Colors.red,  // Change the active tab color to red
      unselectedItemColor: Colors.black54, // Change the inactive tab color
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Add Complaint',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'List Complaint',
        ),
      ],
    );
  }
}
