import 'package:flutter/material.dart';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:kp_police/controllers/push_notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layout/app_bar.dart';
import '../layout/custom_bottom_nav.dart';
import '../layout/custom_drawer.dart';

class AddComplaintScreen extends StatefulWidget {
  @override
  _AddComplaintScreenState createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  int _selectedIndex = 1; // Track the selected index for BottomNavigationBar
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _complainType;
  List<String> _complainTypes = [];  // Initially empty list
  bool _notificationStatus = false; // Track notification status for the category

  final ComplaintsService _complaintsService = ComplaintsService();

  // Device token for notifications (fetch this from Firestore)
  String? deviceToken;

  @override
  void initState() {
    super.initState();
    _loadCategories();  // Load categories when the screen is initialized
  }

  // Update the selected index when a tab is selected
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fetch categories and update the state
  Future<void> _loadCategories() async {
    try {
      List<String> categories = await _complaintsService.fetchCategories();
      setState(() {
        _complainTypes = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  // Fetch sub-category data and associated category information
  Future<void> _fetchSubCategoryData(String selectedType) async {
    try {
      // Query the 'sub_category' collection to match the selected complaint type
      QuerySnapshot subCategoryQuery = await FirebaseFirestore.instance
          .collection('sub_category')
          .where('name', isEqualTo: selectedType)
          .get();

      if (subCategoryQuery.docs.isEmpty) {
        // If no sub-category document is found with the selected type
        print('No sub-category found for the selected complaint type.');
      } else {
        // If a matching sub-category document is found
        DocumentSnapshot subCategoryDoc = subCategoryQuery.docs.first;
        // Fetch the full data from the document
        var subCategoryData = subCategoryDoc.data() as Map<String, dynamic>;

        // Now use the cat_id to fetch the category data
        String catId = subCategoryData['cat_id'];
        _fetchCategoryData(catId);  // Fetch and update category data using cat_id
      }
    } catch (e) {
      print('Error fetching sub-category data: $e');
    }
  }

  // Fetch category data based on cat_id and update notification status
  Future<void> _fetchCategoryData(String catId) async {
    try {
      // Query the 'category' collection to match the cat_id as document ID
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('category')
          .doc(catId) // Use cat_id as document ID
          .get();

      if (categoryDoc.exists) {
        // If the category document exists, fetch the full data
        var categoryData = categoryDoc.data() as Map<String, dynamic>;

        bool notificationStatus = categoryData['notificationStatus'] ?? false;

        // Store the notificationStatus in the state
        setState(() {
          _notificationStatus = notificationStatus;
        });
      } else {
        // If no category document is found with the given cat_id
        print('No category found for the given cat_id: $catId');
      }
    } catch (e) {
      print('Error fetching category data: $e');
    }
  }

  // Submit the complaint form
  void _submitForm() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = user.email ?? '';

      try {
        // Fetch the receptionist's data from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String receptionistName = prefs.getString('receptionist_name') ?? '';
        String receptionistMobile = prefs.getString('receptionist_mobile') ?? '';

        // Fetch the user document from Firestore
        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('user_data')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user data found for the logged-in email.')),
          );
          return;
        }

        DocumentSnapshot userDoc = userQuery.docs.first;

        // Check if notification_id exists
        String? notificationId = userDoc['notification_id'];
        if (notificationId == null || notificationId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification ID is missing in user data.')),
          );
          return;
        }

        // Fetch the superior user with the same notification_id and role
        QuerySnapshot superiorQuery = await FirebaseFirestore.instance
            .collection('user_data')
            .where('notification_id', isEqualTo: notificationId)
            .where('role', isEqualTo: 'superior')
            .get();

        if (superiorQuery.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No superior found with the matching notification ID.')),
          );
        } else {
          DocumentSnapshot superiorDoc = superiorQuery.docs.first;
          deviceToken = superiorDoc['token'];  // Store the device token
          if (deviceToken == null || deviceToken!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('The superior has logged out from their device. Notification will not be sent.')),
            );
          }
        }

        // Proceed with submitting the complaint form
        if (_formKey.currentState?.validate() ?? false) {
          String name = _nameController.text;
          String phone = _phoneController.text;
          String address = _addressController.text;
          String complainType = _complainType!; // Ensure complainType is selected
          String? description = _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null;

          try {
            // Call the service to store the complaint in Firestore
            DocumentReference complaintRef = await _complaintsService.storeComplaint(
              name: name,
              phone: phone,
              address: address,
              complainType: complainType,
              description: description,
              receptionistName: receptionistName,   // Add the receptionist name
              receptionistMobile: receptionistMobile,  // Add the receptionist mobile number
              editStatus: true,
              policeStation: userDoc['police_station'],
              userId: user.uid,
            );

            // **NEW CODE STARTS HERE**
            // Store the complaint document ID in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('last_complaint_id', complaintRef.id);
            // **NEW CODE ENDS HERE**

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Complaint submitted successfully!')),
            );

            // Trigger a notification after successful complaint submission only if notificationStatus is true and token is not empty
            if (_notificationStatus && deviceToken != null && deviceToken!.isNotEmpty) {
              String notificationMessage =
                  'Name: $name\n\nPhone: $phone\n\nAddress: $address\n\nComplain Type: $complainType\n\nDescription: ${description ?? 'No description provided'}';

              String notificationTitle = '$complainType added';

              await PushNotificationService.sendNotification(
                deviceToken!,
                context,
                notificationMessage,
                notificationTitle, // Pass the title
              );
            }

            Navigator.pushReplacementNamed(context, '/thank-you');

          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to submit complaint: $e')),
            );
          }
        }
      } catch (e) {
        print('Error fetching user data or users with matching notification_id: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The Superior Device is currently not logged in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Add Complaint", showBackButton: false),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              // Name of Complaint
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Name of Complaint"),
                  hintText: "Enter Name of Complaint",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter the name of the complaint' : null,
              ),
              SizedBox(height: 20),
              // Phone No
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Phone No"),
                  hintText: "Enter Phone No",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              SizedBox(height: 20),
              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Address"),
                  hintText: "Enter Address",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter the address' : null,
              ),
              SizedBox(height: 20),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Description (Optional)"),
                  hintText: "Enter Description",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20),
              // Complaint Type (Dropdown) - Dynamically populated
              if (_complainTypes.isEmpty)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Loading categories...'),
                  ],
                )
              else
                DropdownButtonFormField<String>(
                  value: _complainType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    label: Text("Complain Type"),
                    hintText: "Complain Type",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                  items: _complainTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        overflow: TextOverflow.ellipsis, // Prevent overflow with ellipsis
                        maxLines: 1, // Limit to one line
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _complainType = value;
                    });
                    if (value != null) {
                      // Call the function to fetch sub-category data when the selection changes
                      _fetchSubCategoryData(value);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Please select a complain type' : null,
                  isExpanded: true,
                ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFa3d95d),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("Submit Complaint", style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
