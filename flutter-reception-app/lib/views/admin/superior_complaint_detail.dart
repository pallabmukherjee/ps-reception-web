import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wbpreception/controllers/complaints_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isUpdating = false;
  late Map<String, dynamic> _complaint;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    if (_complaint['address'] == null || _complaint['description'] == null) {
      _loadComplaintDetails();
    } else {
      _noteController.text = _complaint['note'] ?? '';
    }
  }

  Future<void> _loadComplaintDetails() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dutyStart = prefs.getString('duty_start_time');
      final fullComplaint = await _complaintsService.fetchComplaint(_complaint['id'], dutyStartTime: dutyStart);
      setState(() {
        _complaint = fullComplaint;
        _isLoading = false;
        _noteController.text = _complaint['note'] ?? '';
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

  Future<void> _submitUpdate() async {
    if (_noteController.text.isEmpty) return;
    setState(() => _isUpdating = true);
    try {
      // Android App only updates the Superior Note.
      // We pass the current action values to ensure they aren't cleared by the controller if it's not smart enough.
      await _complaintsService.updateAction(
        _complaint['id'], 
        _complaint['action_taken'] ?? '', 
        _complaint['action_details'] ?? '', 
        _noteController.text
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note updated successfully')));
      setState(() {
        _complaint['note'] = _noteController.text;
        _isUpdating = false;
      });
    } catch (e) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
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
      DateTime dateTime = DateTime.parse(timestamp).toLocal();
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
                  const SizedBox(height: 32),
                  _buildNoteUpdateSection(),
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

  Widget _buildNoteUpdateSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("OFFICIAL INSTRUCTIONS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF00137F), letterSpacing: 1.5)),
          const SizedBox(height: 24),
          
          const Text("SUPERIOR NOTE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Enter instructions or guidance here...",
              fillColor: const Color(0xFFF8FAFC),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isUpdating ? null : _submitUpdate,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00137F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: _isUpdating 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("SAVE OFFICIAL NOTE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
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
            "${_complaint['receptionist_name'] ?? _complaint['receptionist']?['name'] ?? 'N/A'} (${_complaint['receptionist_mobile'] ?? _complaint['receptionist']?['phone_number'] ?? 'N/A'})", isLongText: true),
          _buildInfoRow(Icons.watch_later_rounded, "Logged On", formatTimestamp(_complaint['created_at'])),
          if (_complaint['action_taken'] != null) ...[
            const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F5F9)),
            _buildActionDisplayRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildActionDisplayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 20, color: Colors.emerald),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ACTION TAKEN (FROM WEB)", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.emerald, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(_complaint['action_taken'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                if (_complaint['action_details'] != null)
                  Text(_complaint['action_details'], style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4)),
              ],
            ),
          ),
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
            child: OutlinedButton.icon(
              onPressed: _deleteComplaint,
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              label: const Text("DELETE JURISDICTIONAL RECORD"),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
          ),
      ],
    );
  }
}
