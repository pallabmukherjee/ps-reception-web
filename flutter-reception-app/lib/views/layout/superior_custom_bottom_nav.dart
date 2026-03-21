import 'package:flutter/material.dart';

class SuperiorCustomBottomNavigationBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int selectedIndex;

  SuperiorCustomBottomNavigationBar({required this.onTabSelected, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        // Handle tab selection and navigate to appropriate route
        onTabSelected(index);
        switch (index) {
          case 0: // Home
            Navigator.pushReplacementNamed(context, '/superiorhome');
            break;
          case 1: // List Complaint
            Navigator.pushReplacementNamed(context, '/superior-list-complaint');
            break;
          case 2: // Complaint Detail
            Navigator.pushReplacementNamed(context, '/superior-complaint-detail');
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
          icon: Icon(Icons.list_alt),
          label: 'List Complaint',
        ),
      ],
    );
  }
}
