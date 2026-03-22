import 'package:flutter/material.dart';
import 'package:kp_police/controllers/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
          color: Color(0xFFFAF9F6),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        ],
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            labelText: "Email",
                            hintText: "Enter your email",
                            labelStyle: TextStyle(color: Colors.black, fontSize: 19),
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            label: Text("Password"),
                            hintText: "Enter your Password",
                            labelStyle: TextStyle(color: Colors.black, fontSize: 19),
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 17),
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
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
                              String loginMessage = await AuthService.loginWithEmail(
                                  emailController.text, passwordController.text);
                              if (loginMessage == "Login Successfully") {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                String? role = prefs.getString('user_role');
                                
                                if (role == "admin") {
                                  Navigator.pushReplacementNamed(context, "/adminhome");
                                } else if(role == "superior") {
                                  Navigator.pushReplacementNamed(context, "/superiorhome");
                                }
                                else {
                                  Navigator.pushReplacementNamed(context, "/home");
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      loginMessage,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFdf0100),
                            ),
                            child: Text(
                              "Login",
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () {
                        Navigator.pushNamed(context, "/forgot_password");
                      }, child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF00137F),
                        ),
                      )
                      ),
                      TextButton(onPressed: () {
                        Navigator.pushNamed(context, "/signup");
                      }, child: Text(
                        "Register Now",
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF00137F),
                        ),
                      )
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
