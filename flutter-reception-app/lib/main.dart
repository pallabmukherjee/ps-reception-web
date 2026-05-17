import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:wbpreception/controllers/auth_service.dart';
import 'package:wbpreception/controllers/notification_polling_service.dart';
import 'package:wbpreception/controllers/notification_service.dart';
import 'package:wbpreception/views/admin/complaint_detail.dart';
import 'package:wbpreception/views/admin/complaint_list.dart';
import 'package:wbpreception/views/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/ChangePasswordScreen.dart';
import 'views/ForgotPasswordScreen.dart';

import 'views/admin/add_complaint.dart';
import 'views/admin/edit_complaint_screen.dart';
import 'views/admin/superior_complaint_detail.dart';
import 'views/admin/superior_complaint_list.dart';
import 'views/admin_home_page.dart';
import 'views/home_page.dart';
import 'views/login_page.dart';
import 'views/message.dart';
import 'views/signup_page.dart';
import 'views/superior_home_page.dart';
import 'views/admin/ThankYouScreen.dart';
import 'views/admin/receptionistFormScreen.dart';
import 'views/admin/statistics_screen.dart';


final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register background handler BEFORE Firebase initialization
  FirebaseMessaging.onBackgroundMessage(
      PushNotifications.firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp();

  // Initialize Local notifications
  await PushNotifications.localNotiInit();

  // Initialize Firebase Messaging
  await PushNotifications.init();

  // For handling in terminated state
  final RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print("Launched from terminated state");
    final String? cid = message.data['complaint_id']?.toString();
    if (cid != null) PushNotifications.shownComplaintIds.add(cid);
    Future.delayed(const Duration(seconds: 1), () {
      PushNotifications.navigateToComplaint(message.data);
    });
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WBP Reception',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00137F),
          primary: const Color(0xFF00137F),
          secondary: const Color(0xFFFF0000),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00137F),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF00137F), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00137F),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
      navigatorKey: navigatorKey,
      initialRoute: "/check_user",
      routes: {
        "/check_user": (context) => const CheckUser(),
        "/home": (context) => const HomePage(),
        "/adminhome": (context) => const AdminHomePage(),
        "/superiorhome": (context) => const SuperiorHomePage(),
        "/login": (context) => const LoginPage(),
        "/signup": (context) => const SignupPage(),
        "/message": (context) => const Message(),
        "/add_complaint": (context) =>  AddComplaintScreen(),
        "/list_complaint": (context) =>  ComplaintListScreen(),
        "/superior-list-complaint": (context) =>  SuperiorComplaintListScreen(),
        "/superior-statistics": (context) =>  StatisticsScreen(),
        '/superior-complaint-detail': (context) => SuperiorComplaintDetailScreen(complaint: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
        '/complaint_detail': (context) => ComplaintDetailScreen(complaint: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
        '/edit_complaint': (context) => EditComplaintScreen(complaint: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
        "/profile": (context) =>  ProfileScreen(),
        '/change_password': (context) => ChangePasswordScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/thank-you': (context) => ThankYouScreen(),
        '/receptionist': (context) => ReceptionistFormScreen(),
      },
    );
  }
}


class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  // Check if the user is logged in or not
  void _checkUserLoginStatus() async {
    try {
      bool isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? role = prefs.getString('user_role');

        if (role != null) {
          // Start polling for notifications
          NotificationPollingService.startPolling();

          // Update FCM token on app start
          PushNotifications.getDeviceToken().then((token) {
            AuthService.updateFcmToken(token);
          });

          if (role == "admin" || role == "super") {
            print("User is an admin, navigating to /adminhome");
            Navigator.pushReplacementNamed(context, "/adminhome");
          } else if (role == "superior") {
            print("User is a superior, navigating to /superiorhome");
            Navigator.pushReplacementNamed(context, "/superiorhome");
          } else {
            print("User is a regular user, navigating to /home");
            Navigator.pushReplacementNamed(context, "/home");
          }
        } else {
          print("Role not found, navigating to /login");
          Navigator.pushReplacementNamed(context, "/login");
        }
      } else {
        print("User is not logged in, navigating to /login");
        Navigator.pushReplacementNamed(context, "/login");
      }
    } catch (e) {
      print("Error checking user login status: $e");
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Checking user status..."),
          ],
        ),
      ),
    );
  }
}
