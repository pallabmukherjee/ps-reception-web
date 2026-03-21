import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../layout/app_bar.dart';
import '../layout/custom_bottom_nav.dart';
import '../layout/custom_drawer.dart';
import 'complaint_detail.dart'; // Import the detailed complaint screen
import 'edit_complaint_screen.dart'; // Import the edit complaint screen
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ComplaintListScreen extends StatefulWidget {
  @override
  _ComplaintListScreenState createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  int _selectedIndex = 2; // Track the selected index for BottomNavigationBar
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _complaints = [];
  String? _userId; // To store the logged-in user's UID

  List<String> _storedComplaintIds = [];

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
    _getStoredComplaintIds();
  }

  // Fetch the stored complaint ID from SharedPreferences
  Future<void> _getStoredComplaintIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('complaint_ids'); // Retrieve the JSON string
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString); // Decode the JSON string
      setState(() {
        _storedComplaintIds = List<String>.from(jsonList); // Convert to List<String>
      });
    } else {
      setState(() {
        _storedComplaintIds = []; // Initialize as empty if no IDs are found
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fetch the logged-in user's UID
  Future<void> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid; // Get the user's UID
      });
    }
  }

  // Fetch the list of complaints from Firestore where user_id matches the logged-in user's UID
  Future<void> _fetchComplaints() async {
    try {
      // First, get the logged-in user's UID
      await _getUserId();

      if (_userId == null) {
        print('User not logged in');
        return;
      }

      // Fetch complaints where the 'user_id' matches the current logged-in user's UID
      QuerySnapshot complaintSnapshot = await _firestore
          .collection('complaints')
          .where('user_id', isEqualTo: _userId)
          .get();  // Don't apply the orderBy 'timestamp' here

      // Now, sort the complaints by 'timestamp' on the client side
      List<DocumentSnapshot> filteredComplaints = complaintSnapshot.docs.where((complaint) {
        return _storedComplaintIds.contains(complaint.id); // Only include complaints with matching IDs
      }).toList();
      filteredComplaints.sort((a, b) {
        Timestamp timestampA = a['timestamp'];
        Timestamp timestampB = b['timestamp'];

        // Compare the timestamps (latest first)
        return timestampB.compareTo(timestampA);
      });

      setState(() {
        _complaints = filteredComplaints; // Update the state with filtered complaints
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaints. Error: $e')),
      );
    }
  }

  // Delete a complaint from Firestore
  Future<void> _deleteComplaint(String complaintId) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint deleted successfully.')),
      );
      // Re-fetch complaints after deletion
      _fetchComplaints();
    } catch (e) {
      print('Error deleting complaint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete complaint.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Complaint List", showBackButton: false),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(10.0), // Padding for the entire body
        child: Column(
          children: [
            SizedBox(height: 10), // Add some space between the ID text and the ListView
            Expanded(
              child: _complaints.isEmpty
                  ? Container(
                width: double.infinity, // Full width container
                padding: EdgeInsets.all(20.0), // Optional padding for better spacing
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CircularProgressIndicator(), // Show loading spinner while fetching data
                    ),
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
                  // Check the value of 'edit_status'
                  bool canEditOrDelete = complaint['edit_status'] == true;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    elevation: 1,
                    child: ListTile(
                      title: Text(complaint['name'] ?? 'No name provided'),
                      subtitle: Text(complaint['complainType'] ?? 'No description provided'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintDetailScreen(
                              complaint: complaint,
                            ),
                          ),
                        );
                      },
                      trailing: canEditOrDelete
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,  // Align the buttons to the right end
                        mainAxisSize: MainAxisSize.min,  // Make Row only take the necessary space
                        children: [
                          // Edit Icon
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.blue,  // Blue color for edit button
                            onPressed: () {
                              // Navigate to the edit complaint screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditComplaintScreen(
                                    complaint: complaint,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Delete Icon
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,  // Red color for delete button
                            onPressed: () {
                              // Confirm deletion
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
                                        _deleteComplaint(complaint.id);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )
                          : null, // If edit_status is false, don't show the buttons
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
