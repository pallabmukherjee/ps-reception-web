import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    }

    print('Payload: $payload');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Alert Details", showBackButton: true),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: payload.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // High Alert Header
                  Text(
                    payload['title'] ?? '🚨 HIGH ALERT 🚨',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Category Name in Red
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "CATEGORY",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                        ),
                        Text(
                          '${payload['category_name'] ?? payload['sub_category_name'] ?? 'CRITICAL CASE'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),

                  // Complainant Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.person, "Complainant", payload['complainant_name'] ?? 'N/A'),
                          Divider(height: 30),
                          _buildDetailRow(Icons.phone, "Phone No.", payload['phone'] ?? 'N/A'),
                          Divider(height: 30),
                          _buildDetailRow(Icons.description, "Details", payload['message'] ?? 'New critical complaint registered.'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/superior-list-complaint');
                      },
                      icon: Icon(Icons.list_alt, color: Colors.black),
                      label: Text("VIEW ALL COMPLAINTS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFa3d95d),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No notification data available.',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFF00137F), size: 28),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
