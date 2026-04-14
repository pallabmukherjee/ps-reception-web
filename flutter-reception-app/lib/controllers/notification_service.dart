import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../main.dart';

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

    // Create New Emergency Channel for Android to ensure fresh settings
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'emergency_channel',
      'Emergency Alerts',
      description: 'Used for critical emergency alerts',
      importance: Importance.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('crunchy_beeps'),
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
      print("FCM Foreground message received: ${message.messageId}");
      print("FCM Message data: ${message.data}");
      print("FCM Message notification: ${message.notification?.title} - ${message.notification?.body}");
      
      // Add Toast for visible debugging
      Fluttertoast.showToast(
        msg: "Received: ${message.notification?.title ?? 'Emergency Notification'}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );

      // Extract title and body from notification OR data
      String title = message.notification?.title ?? message.data['title'] ?? '🚨 Emergency Alert';
      String body = message.notification?.body ?? message.data['message'] ?? 'New high priority complaint registered.';

      showSimpleNotification(
        title: title,
        body: body,
        payload: jsonEncode(message.data),
      );
    });

    // Handle Background Message Interaction
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("FCM Message opened app: ${message.messageId}");
      navigatorKey.currentState?.pushNamed("/message", arguments: message.data);
    });
  }

  // Get FCM Token
  static Future<String?> getDeviceToken({int maxRetries = 3}) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("FCM Device Token: $token");
      return token;
    } catch (e) {
      print("FCM Token fetch error: $e");
      return null;
    }
  }

  // Handle Background Notifications
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("🔔 BACKGROUND FCM: Handling message ${message.messageId}");
    
    // Ensure Firebase is initialized for background processing
    try {
      // Initialize Local notifications specifically for this background process
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );

      // Extract title and body from notification OR data payload
      String title = message.notification?.title ?? message.data['title'] ?? '🚨 Emergency Alert';
      String body = message.notification?.body ?? message.data['message'] ?? 'New alert received.';

      print("🔔 BACKGROUND FCM: Displaying local notification: $title");
      
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'emergency_channel',
        'Emergency Alerts',
        channelDescription: 'Used for critical emergency alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        sound: const RawResourceAndroidNotificationSound('crunchy_beeps'),
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
      print("🔔 BACKGROUND FCM ERROR: $e");
    }
  }

  // Show local notification for background messages
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'emergency_channel',
        'Emergency Alerts',
        channelDescription: 'Used for critical emergency alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        sound: const RawResourceAndroidNotificationSound('crunchy_beeps'),
        icon: '@mipmap/ic_launcher',
      );

      final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        message.notification?.title ?? message.data['title'] ?? '🚨 Emergency Alert',
        message.notification?.body ?? message.data['message'] ?? 'New incident reported.',
        platformDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      print("Error showing local notification in background: $e");
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
      // Request notification permissions for Android 13 and above
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,
      );
      print("Local Notifications Initialized");
    } catch (e) {
      print("Local Notifications Initialization Error: $e");
    }
  }

  // Handle notification tap
  static void onNotificationTap(NotificationResponse notificationResponse) {
    print("Notification tapped with payload: ${notificationResponse.payload}");
    navigatorKey.currentState?.pushNamed("/message", arguments: notificationResponse);
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
        sound: const RawResourceAndroidNotificationSound('crunchy_beeps'),
        icon: '@mipmap/ic_launcher',
      );
      
      final NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      
      await _flutterLocalNotificationsPlugin.show(
          DateTime.now().hashCode, title, body, notificationDetails,
          payload: payload);
      print("Notification displayed: $title");
    } catch (e) {
      print("Error showing simple notification: $e");
    }
  }
}
