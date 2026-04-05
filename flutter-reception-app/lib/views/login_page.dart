import 'package:flutter/material.dart';
import 'package:wbpreception/controllers/auth_service.dart';
import 'package:wbpreception/controllers/notification_polling_service.dart';
import 'package:wbpreception/controllers/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoHeader(),
              const SizedBox(height: 48),
              _buildLoginCard(),
              const SizedBox(height: 24),
              _buildFooterActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'West Bengal ',
                style: TextStyle(
                  color: Color(0xFFFF0000),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: 'Police',
                style: TextStyle(
                  color: Color(0xFF00137F),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'RECEPTION MANAGEMENT SYSTEM',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Authorized Access",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please enter your official credentials",
            style: TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Official Email",
              prefixIcon: Icon(Icons.mail_outline_rounded, color: Color(0xFF00137F), size: 20),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock_outline_rounded, color: Color(0xFF00137F), size: 20),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SIGN IN TO PANEL"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? fcmToken = await PushNotifications.getDeviceToken();
      
      String loginMessage = await AuthService.loginWithEmail(
        emailController.text, 
        passwordController.text,
        fcmToken: fcmToken,
      );
      if (loginMessage == "Login Successfully") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? role = prefs.getString('user_role');
        
        // Start notification polling
        NotificationPollingService.startPolling();
        
        if (mounted) {
          if (role == "admin" || role == "super") {
            Navigator.pushReplacementNamed(context, "/adminhome");
          } else if(role == "superior") {
            Navigator.pushReplacementNamed(context, "/superiorhome");
          } else {
            Navigator.pushReplacementNamed(context, "/home");
          }
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loginMessage), backgroundColor: Colors.red.shade600),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connection error: $e')));
      }
    }
  }

  Widget _buildFooterActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, "/forgot_password"),
          child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF00137F), fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, "/signup"),
          child: const Text("Register Now", style: TextStyle(color: Color(0xFFFF0000), fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}
