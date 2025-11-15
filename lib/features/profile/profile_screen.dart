import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/auth/auth_services/auth_service.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/providers/auth_state_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthService service = AuthService();
    final user = ref.watch(authStateProvider).value;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 150,
              ),
              CircleAvatar(
                radius: 35,
              ),
              SizedBox(
                height: 15,
              ),
              Text.rich(TextSpan(
                  text: "Name: ",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                        text: "${user?.displayName}",
                        style: GoogleFonts.inter(fontWeight: FontWeight.normal))
                  ])),
              SizedBox(
                height: 8,
              ),
              Text.rich(TextSpan(
                  text: "Email: ",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                        text: "${user?.email}",
                        style: GoogleFonts.inter(fontWeight: FontWeight.normal))
                  ])),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 45,
                width: 120,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700]),
                    onPressed: () async {
                      await service.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => AuthGate()),
                          (route) => false,
                        );
                      }
                    },
                    child: Text(
                      "LOG OUT",
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    )),
              )
            ],
          ),
        ));
  }
}
