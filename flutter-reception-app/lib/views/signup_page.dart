import 'package:flutter/material.dart';
import 'package:kp_police/controllers/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Properly dispose the controllers
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                  // Top gap text "KPD RM"
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
                                  text: 'Krishnanagar ',
                                  style: TextStyle(
                                    color: Color(0xFFFF0000), // Red color for "Krishnanagar"
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'PD',
                                  style: TextStyle(
                                    color: Color(0xFF00137F), // Blue color for "PD"
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
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        
                  // Form container
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
                          "Register",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        TextFormField(
                          controller: emailController,
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
                            fontSize: 18, // Font size 18
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), // Rounded corners
                            ),
                            labelText: "Password",
                            hintText: "Enter your Password",
                            labelStyle: TextStyle(color: Colors.black, fontSize: 19),
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                          ),
                          style: TextStyle(
                            color: Colors.black, // Black color for the text
                            fontSize: 18, // Font size 18
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              await AuthService.createAccountWithEmail(emailController.text, passwordController.text).then((value) {
                                if (value == "Account Created") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Account Created"))
                                  );
                                  Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          value,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red.shade400,
                                      )
                                  );
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFdf0100), // Red button background
                            ),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 20, // Font size 20
                                color: Colors.white, // White text color
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
        
                  // Already have an account text
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF000000),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/login");
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 19,
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
