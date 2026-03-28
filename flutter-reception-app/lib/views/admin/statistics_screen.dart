import 'package:flutter/material.dart';
import '../../controllers/complaints_service.dart';
import '../layout/app_bar.dart';
import '../layout/custom_drawer.dart';
import '../layout/superior_custom_bottom_nav.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedIndex = 2;
  bool _isLoading = true;
  Map<String, dynamic>? _statsData;
  final ComplaintsService _complaintsService = ComplaintsService();

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await _complaintsService.fetchStatistics();
      setState(() {
        _statsData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching statistics: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load statistics: $e')),
        );
      }
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Statistics", showBackButton: false),
      drawer: CustomDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchStats,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    SizedBox(height: 24),
                    Text(
                      "CATEGORY DISTRIBUTION",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildStatsList(),
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

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statsData?['station_name'] ?? 'Assigned Station',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
          ),
          SizedBox(height: 8),
          Text(
            "Total Complaints",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "${_statsData?['total'] ?? 0}",
            style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsList() {
    final Map<String, dynamic> stats = Map<String, dynamic>.from(_statsData?['stats'] ?? {});
    final int total = _statsData?['total'] ?? 0;

    if (stats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text("No data available", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: stats.entries.map((entry) {
        final double percentage = total > 0 ? (entry.value / total) : 0;
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${entry.value}", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue)),
                ],
              ),
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "${(percentage * 100).toStringAsFixed(1)}% of total",
                style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
