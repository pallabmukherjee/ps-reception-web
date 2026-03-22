import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _userRole;
  final ComplaintsService _complaintsService = ComplaintsService();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchComplaints();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role');
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchComplaints() async {
    setState(() => _isLoading = true);
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

  void _deleteComplaint(int id) async {
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
      try {
        await _complaintsService.deleteComplaint(id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complaint deleted successfully')));
        _fetchComplaints();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
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
                    bool canEdit = complaint['is_editable'] == true || _userRole == 'admin' || _userRole == 'super';
                    bool canDelete = _userRole == 'admin' || _userRole == 'super' || _userRole == 'superior';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(complaint['complainant_name'] ?? 'No Name'),
                        subtitle: Text("${complaint['sub_category']?['name'] ?? 'N/A'} - ${_formatDate(complaint['created_at'])}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (canEdit)
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context, 
                                    '/edit_complaint',
                                    arguments: complaint
                                  );
                                  if (result == true) _fetchComplaints();
                                },
                              ),
                            if (canDelete)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteComplaint(complaint['id']),
                              ),
                          ],
                        ),
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context, 
                            '/complaint_detail',
                            arguments: complaint
                          );
                          if (result == true) _fetchComplaints();
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
