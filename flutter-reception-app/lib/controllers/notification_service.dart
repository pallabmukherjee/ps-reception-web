import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kp_police/controllers/auth_service.dart';
import 'package:kp_police/controllers/crud_service.dart';

import '../main.dart';

class PushNotifications {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Request notification permission
  static Future<void> init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // Get the device token (if needed for FCM purposes)
    final String? token = await _firebaseMessaging.getToken();
    print("Device token: $token");

    // Initialize local notifications
    await localNotiInit();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_onMessage);

    // Set the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

// Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    await _showLocalNotification(message);
  }


  // get the fcm device token
  static Future getDeviceToken() async {
    final String? token = await _firebaseMessaging.getToken();
    print("Device token: $token");

    bool isUserLoggedin = await AuthService.isLoggedIn();
    if (isUserLoggedin) {
      await CRUDService.saveUserToken(token!);
      print("Token Saved on firestore");
    }

    // if token is changed
    _firebaseMessaging.onTokenRefresh.listen((event) async {
      if (isUserLoggedin) {
        await CRUDService.saveUserToken(token!);
        print("Token Saved on firestore");
      }
    });
  }

  // Initialize Flutter local notifications
  static Future<void> localNotiInit() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your_channel_id', // Must match the channel_id in FCM payload
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true, // Ensure this is true
      sound: RawResourceAndroidNotificationSound('tone'), // Ensure this matches your file name
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
    );

    // Request notification permissions for Android 13 and above
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  // Handle foreground notification
  static Future<void> _onMessage(RemoteMessage message) async {
    if (message.notification != null) {
      print("Foreground notification received");

      // Show local notification when the app is in the foreground
      await _showLocalNotification(message);
    }
  }

  // Show a local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      color: Color(0xFFFF0000),
      sound: RawResourceAndroidNotificationSound('tone'),
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: message.data.toString(),
    );
  }

  // Handle notification tap (foreground)
  static void onNotificationTap(NotificationResponse notificationResponse) {
    print('Notification tapped!');
    print('Payload: ${notificationResponse.payload}');
    final payload = jsonDecode(notificationResponse.payload ?? '{}');
    navigatorKey.currentState!
        .pushNamed("/message", arguments: notificationResponse);
  }

  // show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        sound: RawResourceAndroidNotificationSound('tone')
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }
}
