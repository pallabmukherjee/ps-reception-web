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
  final TextEditingController _noteController = TextEditingController();
  bool _isAddingNote = false;
  late Map<String, dynamic> _complaint;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    // If we only have basic info (like from notification), fetch full details
    if (_complaint['address'] == null || _complaint['description'] == null) {
      _loadComplaintDetails();
    }
  }

  Future<void> _loadComplaintDetails() async {
    setState(() => _isLoading = true);
    try {
      final fullComplaint = await _complaintsService.fetchComplaint(_complaint['id']);
      setState(() {
        _complaint = fullComplaint;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load full record: $e')),
      );
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _submitNote() async {
    if (_noteController.text.isEmpty) return;
    setState(() => _isAddingNote = true);
    try {
      await _complaintsService.addNote(_complaint['id'], _noteController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note added successfully')));
      setState(() {
        _complaint['note'] = _noteController.text;
        _isAddingNote = false;
        _noteController.clear();
      });
    } catch (e) {
      setState(() => _isAddingNote = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add note: $e')));
    }
  }

  void _deleteComplaint() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Official Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This action will permanently remove this Complain Record from the jurisdictional database.'),
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
        await _complaintsService.deleteComplaint(_complaint['id']);
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
      appBar: CustomAppBar(title: "Complain Review", showBackButton: true),
      drawer: CustomDrawer(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Container(
            color: const Color(0xFFF1F5F9),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSuperiorHeader(),
                  const SizedBox(height: 32),
                  _buildSuperiorDetailCard(),
                  if (_complaint['note'] != null) ...[
                    const SizedBox(height: 24),
                    _buildNoteSection(),
                  ],
                  const SizedBox(height: 24),
                  _buildAddNoteField(),
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
              Text("YOUR OFFICIAL NOTE", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.amber.shade900, fontSize: 11, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _complaint['note'] ?? '',
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
        const Text("UPDATE OFFICIAL GUIDANCE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Enter instructions for receptionist...",
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: _isAddingNote ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ) : const Icon(Icons.send_rounded, color: Color(0xFF00137F)),
              onPressed: _isAddingNote ? null : _submitNote,
            ),
          ),
        ),
      ],
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
            Text("ID: #${_complaint['id']}", style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _complaint['complainant_name']?.toUpperCase() ?? 'UNNAMED SUBJECT',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          _complaint['police_station']?['name'] ?? 'Assigned Station',
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
          _buildInfoRow(Icons.phone_in_talk_rounded, "Subject Contact", _complaint['phone'], isPhone: true),
          _buildInfoRow(Icons.pin_drop_rounded, "Residential Address", _complaint['address']),
          _buildInfoRow(Icons.category_rounded, "Complain Type", _complaint['sub_category']?['name']),
          _buildInfoRow(Icons.history_edu_rounded, "Statement", _complaint['description'], isLongText: true),
          _buildInfoRow(Icons.person_pin_rounded, "Receptionist Info", 
            "${_complaint['receptionist']?['name'] ?? 'N/A'}\n${_complaint['receptionist']?['phone_number'] ?? ''}", isLongText: true),
          _buildInfoRow(Icons.watch_later_rounded, "Logged On", formatTimestamp(_complaint['created_at'])),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value, {bool isPhone = false, bool isLongText = false}) {
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
                else
                  Text(value ?? 'N/A', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF334155), height: isLongText ? 1.4 : 1.1)),
              ],
            ),
          ),
        ],
      ),
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
