import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../layout/app_bar.dart';
import '../layout/custom_bottom_nav.dart';
import '../layout/custom_drawer.dart';
import '../../controllers/complaints_service.dart';

class ComplaintListScreen extends StatefulWidget {
  @override
  _ComplaintListScreenState createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  final ComplaintsService _complaintsService = ComplaintsService();

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchComplaints() async {
    try {
      final complaints = await _complaintsService.fetchMyComplaints();
      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaints: $e')),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Complaint List", showBackButton: false),
      drawer: CustomDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? Center(child: Text('No complaints found'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = _complaints[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(complaint['complainant_name'] ?? 'No Name'),
                        subtitle: Text("${complaint['sub_category']?['name'] ?? 'N/A'} - ${_formatDate(complaint['created_at'])}"),
                        onTap: () {
                          Navigator.pushNamed(
                            context, 
                            '/complaint_detail',
                            arguments: complaint
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
