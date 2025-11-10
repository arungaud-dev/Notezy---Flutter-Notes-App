import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 166,
              width: 216,
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "ThinkNote",
              style:
                  GoogleFonts.inter(fontStyle: FontStyle.italic, fontSize: 20),
            ),
            Text(
              "Think batter, note smarter",
              style:
                  GoogleFonts.inter(fontSize: 15, fontStyle: FontStyle.italic),
            ),
            SizedBox(
              height: 40,
            ),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
