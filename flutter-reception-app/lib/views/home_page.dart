import 'package:flutter/material.dart';

import 'layout/app_bar.dart';
import 'layout/custom_drawer.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: "Official Portal"),
      drawer: CustomDrawer(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoSection(),
            const SizedBox(height: 64),
            _buildReviewStatus(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, "/check_user"),
              child: const Text("REFRESH APPROVAL STATUS"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
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

  Widget _buildReviewStatus() {
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.pending_actions_rounded, color: Colors.amber, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            "Account Under Review",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Text(
            "Your official personnel profile is currently pending administrator verification. Please check back later.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
