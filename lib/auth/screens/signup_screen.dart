import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/auth/auth_services/auth_service.dart';
import 'package:notes_app/auth/screens/login_screen.dart';
import 'package:notes_app/features/home/home_screen.dart';
import 'package:notes_app/provider/auth_state_provider.dart';
import 'package:notes_app/widgets/custom_textfield.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<SignupScreen> {
  bool isLoading = false;
  final AuthService service = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> createUser() async {
    try {
      if (_emailController.text.isNotEmpty &&
          _passController.text.isNotEmpty &&
          _nameController.text.isNotEmpty) {
        final message = await service.createUser(
            _emailController.text, _passController.text, _nameController.text);
        if (message != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: Duration(seconds: 1),
            ),
          );
        } else if (message == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account created Successfully.',
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green[700],
            ),
          );

          await FirebaseAuth.instance.currentUser?.reload();

// 2) Force Riverpod to refresh the auth stream/provider
          ref.refresh(authStateProvider);
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (route) => false,
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please Fill the all Fields'),
            duration: Duration(seconds: 1),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
                    height: 166,
                    width: 216,
                    child: Image.asset(
                      "assets/images/pencil.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text.rich(TextSpan(
                  text: "Sign",
                  style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.green[700]),
                  children: [
                    TextSpan(
                        text: "UP",
                        style: GoogleFonts.inter(
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            color: Colors.black))
                  ])),
              SizedBox(
                height: 5,
              ),
              Text(
                "Start capturing your thoughts.",
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
                    icon: Icons.person,
                    hint: "Enter your name",
                    isSecure: false,
                    controller: _nameController),
              ),
              SizedBox(
                height: 14,
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
                        onPressed: isLoading == true
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await createUser();
                              },
                        child: Text(
                          "SIGN UP",
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
                    "Already have an account?",
                    style: GoogleFonts.inter(fontSize: 15),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: Text(
                        "Log In",
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
