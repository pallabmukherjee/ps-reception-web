import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../layout/app_bar.dart';
import '../layout/custom_bottom_nav.dart';
import '../layout/custom_drawer.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  ComplaintDetailScreen({required this.complaint});

  @override
  _ComplaintDetailScreenState createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  int _selectedIndex = 2;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          SizedBox(height: 3),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
