import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
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

    // Handle payload based on the source (foreground, background, or terminated)
    if (data is RemoteMessage) {
      // For background and terminated state
      payload = data.data;
    } else if (data is NotificationResponse) {
      // For foreground state
      payload = jsonDecode(data.payload!);
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
        mainAxisAlignment: MainAxisAlignment.start, // Align the content to the start of the column
        crossAxisAlignment: CrossAxisAlignment.start, // Align the content to the start horizontally
        children: [
          if (payload.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '${payload['tripID'] ?? 'N/A'}',
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
                      // Navigate to the Superior Complaint List Screen and replace the current route
                      Navigator.pushReplacementNamed(context, '/superior-list-complaint');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFa3d95d),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("Check All Complaint", style: TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
              ],
            )

          else
            const Text(
              'No notification data available.',
              style: TextStyle(fontSize: 18),
            ),
        ],
      ),

    );
  }
}