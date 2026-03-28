import 'package:flutter/material.dart';

class SuperiorCustomBottomNavigationBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int selectedIndex;

  SuperiorCustomBottomNavigationBar({required this.onTabSelected, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == selectedIndex) return;
        onTabSelected(index);
        switch (index) {
          case 0: // Home
            Navigator.pushReplacementNamed(context, '/superiorhome');
            break;
          case 1: // List Complaint
            Navigator.pushReplacementNamed(context, '/superior-list-complaint');
            break;
          case 2: // Statistics
            Navigator.pushReplacementNamed(context, '/superior-statistics');
            break;
        }
      },
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.black54,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Complaints',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Statistics',
        ),
      ],
    );
  }
}
