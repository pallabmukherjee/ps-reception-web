import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
import 'layout/app_bar.dart';
import 'layout/custom_drawer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  DocumentSnapshot? _userData;

  // Controllers for the fields
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  // Fetch user data from Firestore based on email field
  Future<void> _fetchUserData() async {
    if (_user != null) {
      // Query Firestore to find the user by email field
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .where('email', isEqualTo: _user!.email)  // Match the email field
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          _userData = userSnapshot.docs.first; // Assuming there's only one document

          // Check if fields exist and initialize controllers with existing data
          _fullNameController.text = _userData!.get('full_name') ?? '';  // If full_name doesn't exist, set as empty
          _phoneController.text = _userData!.get('phone_number') ?? '';  // If phone_number doesn't exist, set as empty
          _addressController.text = _userData!.get('address') ?? '';  // If address doesn't exist, set as empty
        });
      }
    }
  }

  // Function to update the user data in Firestore and navigate based on role
  Future<void> _updateUserData() async {
    if (_user != null && _userData != null) {
      try {
        // Update the user's data in Firestore
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(_userData!.id) // Use document ID to update the correct document
            .update({
          'full_name': _fullNameController.text,
          'phone_number': _phoneController.text,
          'address': _addressController.text,
        });

        // After updating, fetch the user role from Firestore
        String role = _userData!.get('role') ?? 'user'; // Default to 'user' if no role is found

        // Redirect based on role
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/adminhome');
        } else if (role == 'user') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (role == 'superior') {
          Navigator.pushReplacementNamed(context, '/superiorhome');
        }

        // Show a success message after updating
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        // Show an error message if something goes wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: CustomAppBar(title: "Profile", showBackButton: true),
        drawer: CustomDrawer(),
        body: Center(
          child: Text(
            'No user logged in',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: CustomAppBar(title: "Profile", showBackButton: true),
        drawer: CustomDrawer(),
        body: _userData == null
            ? Center(child: CircularProgressIndicator()) // Show loading until data is fetched
            : SingleChildScrollView(  // Wrap the content with SingleChildScrollView to avoid overflow
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Welcome',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '${_user!.email}',
                  style: TextStyle(fontSize: 22),
                ),
                Text(
                  'Email you can\'t update',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 20),

                // Editable fields
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    label: Text("Full Name"),
                    hintText: "Enter Full Name",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 19),
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                ),
                SizedBox(height: 25),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    label: Text("Mobile Number"),
                    hintText: "Enter Mobile Number",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 19),
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                ),
                SizedBox(height: 25),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    label: Text("Address"),
                    hintText: "Enter Address",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 19),
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                ),
                SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFa3d95d), // Set the background color to #a3d95d
                    ),
                    child: Text(
                      "Update",
                      style: TextStyle(
                        fontSize: 20, // Set the font size to 20
                        color: Colors.white, // Set the text color to white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
