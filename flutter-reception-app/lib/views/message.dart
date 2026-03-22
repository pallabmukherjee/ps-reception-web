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
    // Extract the payload from the arguments
    _extractPayload();
  }

  void _extractPayload() {
    final data = ModalRoute.of(context)!.settings.arguments;

    if (data is NotificationResponse) {
      try {
        // The payload is a string representation of the data Map
        // We need to parse it back to a Map
        String payloadStr = data.payload ?? '{}';
        // Handle potentially malformed JSON or string representation
        if (payloadStr.startsWith('{')) {
          payload = Map<String, dynamic>.from(jsonDecode(payloadStr));
        } else {
          // If it's not a JSON string, it might be just a plain string message
          payload = {'message': payloadStr};
        }
      } catch (e) {
        print("Error parsing payload: $e");
        payload = {'error': 'Failed to parse notification data'};
      }
    }

    // Print the payload for debugging
    print('Payload: $payload');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Notification Details", showBackButton: false),
      drawer: CustomDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (payload.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '${payload['message'] ?? payload['title'] ?? 'New High Priority Complaint Registered'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/superior-list-complaint');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFa3d95d),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("Check All Complaints", style: TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
              ],
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No notification data available.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),

    );
  }
}
