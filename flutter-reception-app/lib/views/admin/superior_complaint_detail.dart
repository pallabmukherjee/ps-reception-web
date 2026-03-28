import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: const Text('Confirm Official Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This action will permanently remove this case record from the jurisdictional database.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('CONFIRM DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      try {
        await _complaintsService.deleteComplaint(widget.complaint['id']);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jurisdictional record removed')));
        Navigator.pop(context, true); 
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Case Review", showBackButton: true),
      drawer: CustomDrawer(),
      body: Container(
        color: const Color(0xFFF1F5F9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSuperiorHeader(),
              const SizedBox(height: 32),
              _buildSuperiorDetailCard(),
              const SizedBox(height: 32),
              _buildAdminActions(),
              const SizedBox(height: 40),
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

  Widget _buildSuperiorHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFF0000).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: const Text("OFFICIAL RECORD", style: TextStyle(color: Color(0xFFFF0000), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
            ),
            const Spacer(),
            Text("ID: #${widget.complaint['id']}", style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.complaint['complainant_name']?.toUpperCase() ?? 'UNNAMED SUBJECT',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          widget.complaint['police_station']?['name'] ?? 'Assigned Station',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00137F)),
        ),
      ],
    );
  }

  Widget _buildSuperiorDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.phone_in_talk_rounded, "Subject Contact", widget.complaint['phone'], isPhone: true),
          _buildInfoRow(Icons.pin_drop_rounded, "Residential Address", widget.complaint['address']),
          _buildInfoRow(Icons.category_rounded, "Complain Type", widget.complaint['sub_category']?['name']),
          _buildInfoRow(Icons.history_edu_rounded, "Statement", widget.complaint['description'], isLongText: true),
          _buildInfoRow(Icons.watch_later_rounded, "Logged On", formatTimestamp(widget.complaint['created_at'])),
          _buildInfoRow(Icons.rule_rounded, "Status", widget.complaint['status']?.toUpperCase(), isStatus: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value, {bool isPhone = false, bool isLongText = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey.shade300),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                const SizedBox(height: 4),
                if (isPhone && value != null)
                  InkWell(
                    onTap: () => _makePhoneCall(value),
                    child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF00137F), decoration: TextDecoration.underline)),
                  )
                else if (isStatus)
                  _buildStatusBadge(value ?? 'PENDING')
                else
                  Text(value ?? 'N/A', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF334155), height: isLongText ? 1.4 : 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'resolved': color = Colors.green; break;
      case 'in progress': color = Colors.orange; break;
      default: color = const Color(0xFFFF0000);
    }
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildAdminActions() {
    return Column(
      children: [
        if (_isDeleting)
          const Center(child: CircularProgressIndicator())
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _deleteComplaint,
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.white),
              label: const Text("DELETE JURISDICTIONAL RECORD"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0000), foregroundColor: Colors.white),
            ),
          ),
      ],
    );
  }
}
