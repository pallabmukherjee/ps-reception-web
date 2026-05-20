import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layout/app_bar.dart';
import 'layout/custom_drawer.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  Map<String, dynamic> payload = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _extractPayload();
  }

  void _extractPayload() {
    final data = ModalRoute.of(context)!.settings.arguments;

    if (data is NotificationResponse) {
      try {
        String payloadStr = data.payload ?? '{}';
        if (payloadStr.startsWith('{')) {
          payload = Map<String, dynamic>.from(jsonDecode(payloadStr));
        } else {
          payload = {'message': payloadStr};
        }
      } catch (e) {
        print("Error parsing payload: $e");
        payload = {'error': 'Failed to parse notification data'};
      }
    } else if (data is Map) {
      payload = Map<String, dynamic>.from(data);
    }
  }

  Future<void> _navigateToComplain() async {
    if (payload['complaint_id'] == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('user_role');

    if (role == 'superior') {
      Navigator.pushNamed(context, '/superior-complaint-detail', arguments: {
        'id': payload['complaint_id'],
        'complainant_name': payload['complainant_name'],
        'phone': payload['phone'],
      });
    } else {
      Navigator.pushNamed(context, '/complaint_detail', arguments: {
        'id': payload['complaint_id'],
        'complainant_name': payload['complainant_name'],
        'phone': payload['phone'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: "Official Alert", showBackButton: true),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: payload.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAlertIcon(),
                  const SizedBox(height: 24),
                  _buildAlertHeader(),
                  const SizedBox(height: 32),
                  _buildDetailsCard(),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _navigateToComplain,
                    icon: const Icon(Icons.zoom_in_rounded),
                    label: const Text("VIEW FULL COMPLAIN RECORD"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00137F), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/adminhome'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text("BACK TO DASHBOARD"),
                  ),
                ],
              )
            : const _EmptyState(),
      ),
    );
  }

  Widget _buildAlertIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF0000), size: 64),
    );
  }

  Widget _buildAlertHeader() {
    return Column(
      children: [
        const Text(
          "SYSTEM NOTIFICATION",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFFF0000), letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        Text(
          payload['title'] ?? 'CRITICAL ALERT',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.person_outline_rounded, "Subject Name", payload['complainant_name'] ?? 'UNKNOWN'),
          _buildDivider(),
          _buildInfoItem(Icons.phone_android_rounded, "Contact ID", payload['phone'] ?? 'N/A'),
          _buildDivider(),
          _buildInfoItem(Icons.feedback_outlined, "Incident Brief", payload['message'] ?? 'Official dispatch notification.', isLast: payload['note'] == null),
          if (payload['note'] != null) ...[
            _buildDivider(),
            _buildInfoItem(Icons.note_alt_outlined, "Superior Note", payload['note'], isLast: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00137F)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F5F9));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 100),
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("No Active Alert Data", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}
