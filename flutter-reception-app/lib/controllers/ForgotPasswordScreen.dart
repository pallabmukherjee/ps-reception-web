import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  // Function to send reset password email
  Future<void> _sendResetPasswordEmail() async {
    String email = _emailController.text;

    if (email.isEmpty) {
      // Show error message if the email is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    try {
      // Send the password reset email
      await _auth.sendPasswordResetEmail(email: email);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent! Check your inbox.')),
      );
      // Optionally navigate the user back to the login screen
      Navigator.pop(context);
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send password reset email: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(  // Wrap the body with SingleChildScrollView
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Color(0xFFFAF9F6), // Full page background color
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top gap text "WB Police RM"
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'West Bengal ',
                                  style: TextStyle(
                                    color: Color(0xFFFF0000), // Red color for "West Bengal "
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Police',
                                  style: TextStyle(
                                    color: Color(0xFF00137F), // Blue color for "Police"
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
                              color: Color(0xFF57007F), // Purple color for "Reception Management"
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Form section background color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Forgot Password",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), // Rounded corners
                            ),
                            labelText: "Email",
                            hintText: "Enter your email",
                            labelStyle: TextStyle(color: Colors.black, fontSize: 19),
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                            filled: true, // Background color
                            fillColor: Colors.white, // White background color for the text field
                          ),
                          style: TextStyle(
                            color: Colors.black, // Black color for the text
                            fontSize: 18, // Font size 15
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _sendResetPasswordEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFdf0100), // Set the background color
                            ),
                            child: Text(
                              "Send Reset Link",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back to the login screen
                        },
                        child: Text(
                          "Back to Login",
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF00137F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
