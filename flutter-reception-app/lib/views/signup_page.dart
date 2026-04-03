import 'package:flutter/material.dart';
import 'package:wbpreception/controllers/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("OFFICIAL REGISTRATION"),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF00137F),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildInstructionHeader(),
              const SizedBox(height: 40),
              _buildSignupCard(),
              const SizedBox(height: 32),
              _buildLoginRedirect(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00137F).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00137F).withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00137F), size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Account activation requires administrator approval after submission.",
              style: TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.bold, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Personnel Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Official Name",
                prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF00137F), size: 20),
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Official Email ID",
                prefixIcon: Icon(Icons.alternate_email_rounded, color: Color(0xFF00137F), size: 20),
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Access Password",
                prefixIcon: Icon(Icons.lock_open_rounded, color: Color(0xFF00137F), size: 20),
              ),
              validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("SUBMIT FOR APPROVAL"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String result = await AuthService.createAccountWithEmail(
        emailController.text,
        passwordController.text,
      );

      if (mounted) {
        if (result == "Registration Successful") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration submitted. Contact admin for activation.')),
          );
          Navigator.pushReplacementNamed(context, "/login");
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result), backgroundColor: Colors.red.shade600),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission error: $e')));
      }
    }
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
          child: const Text("Sign In", style: TextStyle(color: Color(0xFF00137F), fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}
