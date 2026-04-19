import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
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
      print("!!! FOREGROUND FCM RECEIVED: Title: ${message.notification?.title ?? message.data['title']}");
      // Extract title and body from notification OR data
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
      navigatorKey.currentState?.pushNamed("/message", arguments: message.data);
    });

    // Handle messages that launched the app from a terminated state
    final RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 1), () {
        navigatorKey.currentState?.pushNamed("/message", arguments: initialMessage.data);
      });
    }
  }

  // Get FCM Token
  static Future<String?> getDeviceToken({int maxRetries = 3}) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      return null;
    }
  }

  // Handle Background Notifications
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
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

      // Explicitly create the channel in background to ensure it exists
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

      // Extract title and body from notification OR data payload
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
      // Silently fail in background
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
      // Silently fail
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
    } catch (e) {
      // Silently fail
    }
  }

  // Handle notification tap
  static void onNotificationTap(NotificationResponse notificationResponse) {
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
    } catch (e) {
      // Silently fail
    }
  }
}
