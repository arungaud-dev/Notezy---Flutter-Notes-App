import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/auth/screens/signup_screen.dart';
import 'package:notes_app/features/home/home_screen.dart';
import 'package:notes_app/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 163,
                    width: 216,
                    child: Image.asset(
                      "assets/images/stack.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text.rich(TextSpan(
                  text: "Log",
                  style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.green[700]),
                  children: [
                    TextSpan(
                        text: "IN",
                        style: GoogleFonts.inter(
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            color: Colors.black))
                  ])),
              SizedBox(
                height: 5,
              ),
              Text(
                "Welcome back — your ideas are waiting.",
                style: GoogleFonts.inter(
                    fontSize: 15, fontStyle: FontStyle.italic),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomInputText(
                    icon: Icons.email,
                    hint: "Enter your email",
                    isSecure: false,
                    controller: _emailController),
              ),
              SizedBox(
                height: 14,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomInputText(
                    icon: Icons.lock,
                    hint: "Enter your password",
                    isSecure: true,
                    controller: _passController),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 120,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                        },
                        child: Text(
                          "LOGIN",
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        )),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.inter(fontSize: 15),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()));
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700]),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
