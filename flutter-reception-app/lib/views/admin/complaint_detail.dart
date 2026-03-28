import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kp_police/controllers/complaints_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? _userRole;
  final ComplaintsService _complaintsService = ComplaintsService();
  bool _isDeleting = false;
  final TextEditingController _noteController = TextEditingController();
  bool _isAddingNote = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
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

  void _deleteComplaint() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to permanently delete this official record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      try {
        await _complaintsService.deleteComplaint(widget.complaint['id']);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record deleted successfully')));
        Navigator.pop(context, true); 
      } catch (e) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _submitNote() async {
    if (_noteController.text.isEmpty) return;
    setState(() => _isAddingNote = true);
    try {
      await _complaintsService.addNote(widget.complaint['id'], _noteController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note added successfully')));
      setState(() {
        widget.complaint['note'] = _noteController.text;
        _isAddingNote = false;
        _noteController.clear();
      });
    } catch (e) {
      setState(() => _isAddingNote = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add note: $e')));
    }
  }

  String formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
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
    bool canManage = widget.complaint['is_editable'] == true || _userRole == 'admin' || _userRole == 'super';
    bool canAddNote = _userRole == 'superior' || _userRole == 'admin' || _userRole == 'super';

    return Scaffold(
      appBar: CustomAppBar(title: "Complain Details", showBackButton: true),
      drawer: CustomDrawer(),
      body: Container(
        color: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 32),
              _buildDetailCard(),
              if (widget.complaint['note'] != null) ...[
                const SizedBox(height: 24),
                _buildNoteSection(),
              ],
              if (canAddNote) ...[
                const SizedBox(height: 24),
                _buildAddNoteField(),
              ],
              const SizedBox(height: 32),
              if (canManage) _buildActionButtons(),
              const SizedBox(height: 40),
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

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00137F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "COMPLAIN ID: #${widget.complaint['id']}",
            style: const TextStyle(color: Color(0xFF00137F), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.complaint['complainant_name']?.toUpperCase() ?? 'UNNAMED',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 16, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              widget.complaint['police_station']?['name'] ?? 'Unknown Station',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.phone_android_rounded, "Contact Number", widget.complaint['phone'], isPhone: true),
          _buildDivider(),
          _buildInfoRow(Icons.home_work_outlined, "Address", widget.complaint['address']),
          _buildDivider(),
          _buildInfoRow(Icons.shield_outlined, "Complain Category", widget.complaint['sub_category']?['name']),
          _buildDivider(),
          _buildInfoRow(Icons.description_outlined, "Complain Description", widget.complaint['description'], isLongText: true),
          _buildDivider(),
          _buildInfoRow(Icons.person_pin_rounded, "Receptionist Info", 
            "${widget.complaint['receptionist']?['name'] ?? 'N/A'}\n${widget.complaint['receptionist']?['phone_number'] ?? ''}", isLongText: true),
          _buildDivider(),
          _buildInfoRow(Icons.event_available_rounded, "Registration Date", formatTimestamp(widget.complaint['created_at'])),
          _buildDivider(),
          _buildInfoRow(Icons.info_outline_rounded, "Current Status", widget.complaint['status']?.toUpperCase(), isStatus: true),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, color: Colors.amber.shade900, size: 18),
              const SizedBox(width: 8),
              Text("SUPERIOR NOTE", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.amber.shade900, fontSize: 11, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.complaint['note'] ?? '',
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ADD OFFICIAL NOTE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Enter official remarks or instructions...",
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: _isAddingNote ? const CircularProgressIndicator() : const Icon(Icons.send_rounded, color: Color(0xFF00137F)),
              onPressed: _isAddingNote ? null : _submitNote,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value, {bool isPhone = false, bool isLongText = false, bool isStatus = false}) {
    // Hide Pending status
    if (isStatus && (value == null || value.toLowerCase() == 'pending')) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: const Color(0xFF00137F)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1)),
                const SizedBox(height: 4),
                if (isPhone && value != null)
                  InkWell(
                    onTap: () => _makePhoneCall(value),
                    child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF00137F), decoration: TextDecoration.underline)),
                  )
                else if (isStatus)
                  _buildStatusBadge(value ?? '')
                else
                  Text(value ?? 'N/A', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), height: isLongText ? 1.5 : 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    if (status.isEmpty) return const SizedBox.shrink();
    Color color;
    switch (status.toLowerCase()) {
      case 'resolved': color = Colors.green; break;
      case 'in progress': color = Colors.orange; break;
      default: color = const Color(0xFFFF0000);
    }
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F5F9));

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isDeleting)
          const Center(child: CircularProgressIndicator())
        else ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text("MODIFY COMPLAIN"),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/edit_complaint', arguments: widget.complaint);
              if (result == true) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00137F), foregroundColor: Colors.white),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_sweep_rounded),
            label: const Text("DELETE PERMANENTLY"),
            onPressed: _deleteComplaint,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ]
      ],
    );
  }
}
