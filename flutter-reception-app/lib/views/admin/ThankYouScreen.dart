import 'package:flutter/material.dart';

import '../layout/app_bar.dart';
import '../layout/custom_drawer.dart';

class ThankYouScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: "Submission Status", showBackButton: false),
      drawer: CustomDrawer(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSuccessState(),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/adminhome'),
              child: const Text("RETURN TO DASHBOARD"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: Colors.green, size: 64),
          ),
          const SizedBox(height: 32),
          const Text(
            "Complaint Registered",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            "The official case record has been successfully logged into the West Bengal Police central repository.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ],
      ),
    );
  }
}
