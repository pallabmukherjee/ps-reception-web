import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

@pragma('vm:entry-point')
class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize Firebase Messaging
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // Create Emergency Channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'emergency_channel',
      'Emergency Alerts',
      description: 'Used for critical emergency alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Set Foreground Notification Options for iOS
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("!!! FOREGROUND FCM RECEIVED: Title: ${message.notification?.title ?? message.data['title']}");
        String title = message.notification?.title ?? message.data['title'] ?? '🚨 Emergency Alert';
        String body = message.notification?.body ?? message.data['message'] ?? 'New alert received.';

        showSimpleNotification(
          title: title,
          body: body,
          payload: jsonEncode(message.data),
        );
      });

      // Handle Background Message Interaction
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        navigateToComplaint(message.data);
      });
  }

  // Get FCM Token
  static Future<String?> getDeviceToken({int maxRetries = 3}) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Handle Background Notifications
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'emergency_channel',
        'Emergency Alerts',
        description: 'Used for critical emergency alerts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      String title = message.notification?.title ?? message.data['title'] ?? '🚨 Emergency Alert';
      String body = message.notification?.body ?? message.data['message'] ?? 'New alert received.';

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'emergency_channel',
        'Emergency Alerts',
        channelDescription: 'Used for critical emergency alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        icon: '@mipmap/ic_launcher',
      );

      final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().hashCode,
        title,
        body,
        platformDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      print('Error in firebaseMessagingBackgroundHandler: $e');
    }
  }

  // Initialize Flutter local notifications
  static Future<void> localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    try {
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,
      );

      // Request notification permissions for Android 13 and above
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  // Handle notification tap
  @pragma('vm:entry-point')
  static Future<void> onNotificationTap(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload == null) return;
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      await navigateToComplaint(data);
    } catch (e) {
      print('Error in onNotificationTap: $e');
    }
  }

  static Future<void> navigateToComplaint(Map<String, dynamic> data) async {
    final String? complaintIdStr = data['complaint_id']?.toString();
    if (complaintIdStr == null) return;
    final int? complaintId = int.tryParse(complaintIdStr);
    if (complaintId == null) return;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? role = prefs.getString('user_role');
      final String route = role == 'superior' ? '/superior-complaint-detail' : '/complaint_detail';
      navigatorKey.currentState?.pushNamed(route, arguments: {
        'id': complaintId,
        'complainant_name': data['complainant_name'],
        'phone': data['phone'],
      });
    } catch (e) {
      print('Error navigating to complaint: $e');
    }
  }

  // Show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'emergency_channel',
        'Emergency Alerts',
        channelDescription: 'Used for critical emergency alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        icon: '@mipmap/ic_launcher',
      );

      final NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _flutterLocalNotificationsPlugin.show(
          DateTime.now().hashCode, title, body, notificationDetails,
          payload: payload);
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}
