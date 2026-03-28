import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../layout/app_bar.dart';
import '../layout/custom_drawer.dart';
import '../layout/superior_custom_bottom_nav.dart';
import '../../controllers/complaints_service.dart';

class SuperiorComplaintListScreen extends StatefulWidget {
  @override
  _SuperiorComplaintListScreenState createState() => _SuperiorComplaintListScreenState();
}

class _SuperiorComplaintListScreenState extends State<SuperiorComplaintListScreen> {
  int _selectedIndex = 1;
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _userRole;
  final ComplaintsService _complaintsService = ComplaintsService();

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
    setState(() => _selectedIndex = index);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load complaints: $e')),
        );
      }
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Complain Directory", showBackButton: false),
      drawer: CustomDrawer(),
      body: Container(
        color: const Color(0xFFF1F5F9),
        child: Column(
          children: [
            _buildSuperiorSearch(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchComplaints(reset: true),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _complaints.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _complaints.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _complaints.length) {
                                return const Center(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator());
                              }
                              return _buildPremiumComplaintCard(_complaints[index]);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SuperiorCustomBottomNavigationBar(
        onTabSelected: _onTabSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No Jurisdictional Records", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildSuperiorSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00137F), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Search records...",
              hintStyle: const TextStyle(color: Colors.white60),
              prefixIcon: const Icon(Icons.manage_search_rounded, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
            onSubmitted: (val) => _fetchComplaints(reset: true),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate == null ? "SELECT DATE RANGE" : "${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}",
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                        const Icon(Icons.event_note_rounded, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _fetchComplaints(reset: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  minimumSize: const Size(100, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("SEARCH", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumComplaintCard(Map<String, dynamic> complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/superior-complaint-detail', arguments: complaint),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      complaint['complainant_name']?.toUpperCase() ?? 'UNNAMED',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                    ),
                  ),
                  _buildStatusBadge(complaint['status']),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.phone_in_talk_rounded, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _makePhoneCall(complaint['phone'] ?? ''),
                    child: Text(
                      complaint['phone'] ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00137F), decoration: TextDecoration.underline),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd MMM, yyyy').format(DateTime.parse(complaint['created_at'])),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFF1F5F9))),
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 14, color: Color(0xFFFF0000)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      complaint['sub_category']?['name'] ?? 'General Complain',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.blueGrey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(dynamic status) {
    if (status == null || status.toString().toLowerCase() == 'pending') {
      return const SizedBox.shrink();
    }
    Color color;
    String statusStr = status.toString();
    switch (statusStr.toLowerCase()) {
      case 'resolved': color = Colors.green; break;
      case 'in progress': color = Colors.orange; break;
      default: color = const Color(0xFFFF0000);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(statusStr.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }
}
