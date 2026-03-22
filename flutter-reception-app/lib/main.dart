import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kp_police/controllers/auth_service.dart';
import 'package:kp_police/controllers/notification_polling_service.dart';
import 'package:kp_police/controllers/notification_service.dart';
import 'package:kp_police/views/admin/complaint_detail.dart';
import 'package:kp_police/views/admin/complaint_list.dart';
import 'package:kp_police/views/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/ChangePasswordScreen.dart';
import 'controllers/ForgotPasswordScreen.dart';

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


final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local notifications
  await PushNotifications.localNotiInit();

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
          if (role == "admin" || role == "super") {
            print("User is an admin, navigating to /adminhome");
            Navigator.pushReplacementNamed(context, "/adminhome");
          } else if (role == "superior") {
            print("User is a superior, starting polling and navigating to /superiorhome");
            NotificationPollingService.startPolling();
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
