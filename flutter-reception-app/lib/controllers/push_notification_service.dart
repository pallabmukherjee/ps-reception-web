import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;


class PushNotificationService {

  static Future<String> getAccessToken() async {
    // DO NOT HARDCODE SECRETS IN CODE. 
    // This should ideally be fetched from a secure backend or environment variables.
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "YOUR_PROJECT_ID",
      "private_key_id": "YOUR_PRIVATE_KEY_ID",
      "private_key": "YOUR_PRIVATE_KEY",
      "client_email": "YOUR_CLIENT_EMAIL",
      "client_id": "YOUR_CLIENT_ID",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "YOUR_CLIENT_X509_CERT_URL",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // get the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client
    );

    client.close();

    return credentials.accessToken.data;
  }

  static Future<void> sendNotification(String deviceToken, BuildContext context, String tripID, String notificationTitle) async {
    final String accessToken = await getAccessToken();

    final Map<String, dynamic> notificationBody = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": notificationTitle,
          "body": "A new complaint has been added.",
        },
        "android": { 
          "notification": {
            "sound": "tone",
            "channel_id": "your_channel_id" 
          }
        },
        "data": {
          "tripID": tripID,
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        },
      },
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/kpd-reception/messages:send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(notificationBody),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }
}
