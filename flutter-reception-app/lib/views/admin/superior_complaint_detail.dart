import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kp_police/controllers/complaints_service.dart';

import '../layout/app_bar.dart';
import '../layout/custom_drawer.dart';
import '../layout/superior_custom_bottom_nav.dart';

class SuperiorComplaintDetailScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  SuperiorComplaintDetailScreen({required this.complaint});

  @override
  _SuperiorComplaintDetailScreenState createState() => _SuperiorComplaintDetailScreenState();
}

class _SuperiorComplaintDetailScreenState extends State<SuperiorComplaintDetailScreen> {
  int _selectedIndex = 1;
  final ComplaintsService _complaintsService = ComplaintsService();
  bool _isDeleting = false;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _deleteComplaint() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Complaint'),
        content: Text('Are you sure you want to delete this complaint?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      try {
        await _complaintsService.deleteComplaint(widget.complaint['id']);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complaint deleted successfully')));
        Navigator.pop(context, true); // Go back and indicate success
      } catch (e) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  String formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('dd MMM yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildComplaintField(String title, String? value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black12,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: -',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Complaint Details", showBackButton: true),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComplaintField('Name', widget.complaint['complainant_name']),
              SizedBox(height: 7),
              _buildComplaintField('Phone', widget.complaint['phone']),
              SizedBox(height: 7),
              _buildComplaintField('Address', widget.complaint['address']),
              SizedBox(height: 7),
              _buildComplaintField('Complaint Type', widget.complaint['sub_category']?['name']),
              SizedBox(height: 7),
              _buildComplaintField('Description', widget.complaint['description']),
              SizedBox(height: 7),
              _buildComplaintField('Police Station', widget.complaint['police_station']?['name']),
              SizedBox(height: 7),
              _buildComplaintField('Date & Time', formatTimestamp(widget.complaint['created_at'])),
              SizedBox(height: 20),
              if (_isDeleting)
                Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _deleteComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("Delete Complaint", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
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
