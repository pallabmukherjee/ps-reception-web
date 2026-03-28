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
  bool _isLoadingMore = false;
  String? _userRole;
  final ComplaintsService _complaintsService = ComplaintsService();

  // Search and Filters
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 1;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchComplaints(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchComplaints();
    }
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

  Future<void> _fetchComplaints({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _complaints = [];
        _hasMore = true;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await _complaintsService.fetchMyComplaints(
        search: _searchController.text,
        startDate: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : null,
        endDate: _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
        page: _currentPage,
      );

      final List<dynamic> fetchedData = response['data'];
      setState(() {
        _complaints.addAll(List<Map<String, dynamic>>.from(fetchedData));
        _isLoading = false;
        _isLoadingMore = false;
        _currentPage++;
        _hasMore = response['next_page_url'] != null;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
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
        _fetchComplaints(reset: true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchComplaints(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Complaint List", showBackButton: false),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchComplaints(reset: true),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _complaints.isEmpty
                      ? Center(child: Text('No complaints found'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(10),
                          itemCount: _complaints.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _complaints.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final complaint = _complaints[index];
                            bool canEdit = complaint['is_editable'] == true || _userRole == 'admin' || _userRole == 'super';
                            bool canDelete = _userRole == 'admin' || _userRole == 'super' || _userRole == 'superior';

                            return _buildComplaintCard(complaint, canEdit, canDelete);
                          },
                        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by name, phone, or type...",
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _fetchComplaints(reset: true);
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            onSubmitted: (val) => _fetchComplaints(reset: true),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate == null
                              ? "Select Date Range"
                              : "${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}",
                          style: TextStyle(fontSize: 13),
                        ),
                        Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              if (_startDate != null)
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                    _fetchComplaints(reset: true);
                  },
                ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _fetchComplaints(reset: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFa3d95d),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Filter", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint, bool canEdit, bool canDelete) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context, 
            '/complaint_detail',
            arguments: complaint
          );
          if (result == true) _fetchComplaints(reset: true);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      complaint['complainant_name'] ?? 'No Name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildStatusBadge(complaint['status'] ?? 'Pending'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(complaint['phone'] ?? 'N/A'),
                  SizedBox(width: 15),
                  Icon(Icons.category, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Expanded(child: Text(complaint['sub_category']?['name'] ?? 'N/A', overflow: TextOverflow.ellipsis)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Expanded(child: Text(complaint['police_station']?['name'] ?? 'N/A', style: TextStyle(color: Colors.blue.shade700))),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(complaint['created_at']),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Row(
                    children: [
                      if (canEdit)
                        IconButton(
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context, 
                              '/edit_complaint',
                              arguments: complaint
                            );
                            if (result == true) _fetchComplaints(reset: true);
                          },
                        ),
                      if (canDelete)
                        IconButton(
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _deleteComplaint(complaint['id']),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'resolved':
        bgColor = Colors.green;
        break;
      case 'in progress':
        bgColor = Colors.blue;
        break;
      default:
        bgColor = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
