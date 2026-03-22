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
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Home Page"),
      drawer: CustomDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'West Bengal ',
                    style: TextStyle(
                      color: Color(0xFFFF0000),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Police',
                    style: TextStyle(
                      color: Color(0xFF00137F),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Reception Management',
              style: TextStyle(
                color: Color(0xFF57007F),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Your profile under review",
              style: TextStyle(
                fontSize: 17,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CheckUser()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFa3d95d),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("Check Approve status", style: TextStyle(fontSize: 15, color: Colors.black)),
            ),
          ],
        ),
      ),

    );
  }
}
