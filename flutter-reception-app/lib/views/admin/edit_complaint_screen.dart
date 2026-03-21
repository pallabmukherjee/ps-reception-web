import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../layout/app_bar.dart';
import '../layout/custom_drawer.dart';

class EditComplaintScreen extends StatefulWidget {
  final DocumentSnapshot complaint;

  EditComplaintScreen({required this.complaint});

  @override
  _EditComplaintScreenState createState() => _EditComplaintScreenState();
}

class _EditComplaintScreenState extends State<EditComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _complainTypeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  List<String> _complainTypes = [];  // To hold complaint types
  String? _selectedComplainType;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.complaint['name'] ?? '';
    _phoneController.text = widget.complaint['phone'] ?? '';
    _addressController.text = widget.complaint['address'] ?? '';
    _complainTypeController.text = widget.complaint['complainType'] ?? '';
    _descriptionController.text = widget.complaint['description'] ?? '';

    // Fetch the complaint types from Firestore
    _fetchComplaintTypes();
  }

  // Fetch complaint types from Firestore
  Future<void> _fetchComplaintTypes() async {
    try {
      // Fetch categories (complain types) from Firestore
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('sub_category')
          .get();

      List<String> categories = [];
      for (var doc in categorySnapshot.docs) {
        categories.add(doc['name']);
      }

      setState(() {
        _complainTypes = categories;
        _selectedComplainType = widget.complaint['complainType'];  // Pre-select the complaint type
      });
    } catch (e) {
      print('Error fetching complaint types: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaint types.')),
      );
    }
  }

  // Update the complaint in Firestore
  Future<void> _updateComplaint() async {
    try {
      await FirebaseFirestore.instance.collection('complaints').doc(widget.complaint.id).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'complainType': _complainTypeController.text,
        'description': _descriptionController.text,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint updated successfully.')),
      );

      // Replace the current screen with the ComplaintListScreen
      Navigator.pushReplacementNamed(context, '/list_complaint');  // Navigate to ComplaintListScreen
    } catch (e) {
      print('Error updating complaint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update complaint.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Update Complaint", showBackButton: true),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
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
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Phone No"),
                  hintText: "Enter Phone No",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter the Phone No' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Address"),
                  hintText: "Enter Address",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter the Address' : null,
              ),
              SizedBox(height: 20),
              // Complaint Type Dropdown
              _complainTypes.isEmpty
                  ? Center(child: CircularProgressIndicator())  // Show loading indicator while fetching data
                  : DropdownButtonFormField<String>(
                value: _selectedComplainType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  label: Text("Complain Type"),
                  hintText: "Complain Type",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                ),
                items: _complainTypes.map((complainType) {
                  return DropdownMenuItem<String>(
                    value: complainType,
                    child: Text(
                      complainType,
                      overflow: TextOverflow.ellipsis, // Prevent overflow with ellipsis
                      maxLines: 1, // Limit to one line
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _complainTypeController.text = value ?? '';
                    _selectedComplainType = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select the complain type'
                    : null,
                isExpanded: true,
              ),
              SizedBox(height: 20),
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateComplaint();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFa3d95d),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("Update Complaint", style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
