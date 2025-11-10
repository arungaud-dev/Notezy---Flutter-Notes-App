import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInputText extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isSecure;
  final TextEditingController controller;
  const CustomInputText(
      {super.key,
      required this.icon,
      required this.hint,
      required this.isSecure,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.grey.withOpacity(0.06)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: TextField(
          controller: controller,
          obscureText: isSecure,
          decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: Colors.black.withOpacity(0.5),
              ),
              hintStyle: GoogleFonts.inter(
                  color: Colors.black.withOpacity(0.5), fontSize: 16)),
        ),
      ),
    );
  }
}
