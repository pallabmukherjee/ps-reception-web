import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../layout/app_bar.dart';
import '../layout/superior_custom_bottom_nav.dart';
import '../layout/custom_drawer.dart';
import 'superior_complaint_detail.dart';

class SuperiorComplaintListScreen extends StatefulWidget {
  @override
  _SuperiorComplaintListScreenState createState() =>
      _SuperiorComplaintListScreenState();
}

class _SuperiorComplaintListScreenState
    extends State<SuperiorComplaintListScreen> {
  int _selectedIndex = 1;
  List<DocumentSnapshot> _complaints = []; // List to hold fetched complaints

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fetch user details from Firestore based on email
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current authenticated user

    if (user != null) {
      // Print user details
      print('User Email: ${user.email}');

      try {
        // Fetch user data from the user_data collection based on the email field
        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('user_data')
            .where('email', isEqualTo: user.email) // Match email field
            .limit(1) // Limit to one document
            .get();

        if (userQuery.docs.isEmpty) {
          print('No user data found for email: ${user.email}');
          return;
        }

        DocumentSnapshot userDoc = userQuery.docs.first;

        // Print the data of the user document
        print('User Data: ${userDoc.data()}');

        // Check if 'police_station' exists and print it
        if (userDoc['police_station'] != null) {
          String policeStationId = userDoc['police_station'];
          print('Police Station ID: $policeStationId');

          // Fetch and print all complaints for this police station
          _fetchComplaints(policeStationId);
        } else {
          print('No police station data found for this user.');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    } else {
      print('No user is logged in.');
    }
  }

  // Fetch complaints based on police_station ID
  Future<void> _fetchComplaints(String policeStationId) async {
    try {
      // Fetch complaints from Firestore where 'police_station' matches
      QuerySnapshot complaintSnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('police_station', isEqualTo: policeStationId) // Filter by police_station
          .get();

      if (complaintSnapshot.docs.isEmpty) {
        print('No complaints found for police station: $policeStationId');
        return;
      }

      // Sort the complaints by timestamp (latest first)
      List<DocumentSnapshot> sortedComplaints = complaintSnapshot.docs;
      sortedComplaints.sort((a, b) {
        Timestamp timestampA = a['timestamp'];
        Timestamp timestampB = b['timestamp'];
        return timestampB.compareTo(timestampA); // Sorting by latest timestamp first
      });

      setState(() {
        _complaints = sortedComplaints; // Store the sorted complaints in the list
      });
    } catch (e) {
      print('Error fetching complaints: $e');
    }
  }


  Future<void> _deleteComplaint(String complaintId) async {
    try {
      // Delete complaint from Firestore
      await FirebaseFirestore.instance.collection('complaints').doc(complaintId).delete();
      print('Complaint deleted successfully.');

      // Remove the deleted complaint from the list locally
      setState(() {
        _complaints.removeWhere((complaint) => complaint.id == complaintId);
      });

      // Optionally, show a Snackbar for feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Complaint deleted successfully'),
      ));
    } catch (e) {
      print('Error deleting complaint: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting complaint'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Complaint List", showBackButton: false),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _complaints.isEmpty
            ? Container(
          width: double.infinity, // Full width container
          padding: EdgeInsets.all(20.0), // Optional padding for better spacing
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(), // Show loading spinner while fetching data
              SizedBox(height: 10), // Add some space between the loading spinner and text
              Text(
                'No complaints available', // Text to show when no complaints exist
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center, // Center-align the text
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _complaints.length,
          itemBuilder: (context, index) {
            var complaint = _complaints[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              elevation: 5,
              child: ListTile(
                title: Text(complaint['name'] ?? 'No name provided'),
                subtitle: Text(complaint['complainType'] ?? 'No description provided'),
                onTap: () {
                  // Navigate to the detailed complaint view if necessary
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuperiorComplaintDetailScreen(
                        complaint: complaint,
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red, // Red color for delete button
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Complaint'),
                        content: Text('Are you sure you want to delete this complaint?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteComplaint(complaint.id); // Delete complaint if confirmed
                              Navigator.pop(context);
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SuperiorCustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}