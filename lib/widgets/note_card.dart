import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String body;
  final bool isStar;
  final String time;
  final String category;
  final VoidCallback callback;
  final String color;

  const NoteCard(
      {super.key,
      required this.title,
      required this.body,
      required this.isStar,
      required this.time,
      required this.category,
      required this.callback,
      required this.color});

  @override
  Widget build(BuildContext context) {
    MaterialColor getColor() {
      // debugPrint("----------------------------CATEGORY: $title, COLOR: $color");
      switch (color) {
        case "green":
          return Colors.green;
        case "yellow":
          return Colors.yellow;
        case "pink":
          return Colors.pink;
        case "red":
          return Colors.red;
        case "purple":
          return Colors.deepPurple;
        case "amber":
          return Colors.amber;
        default:
          return Colors.blue;
      }
    }

    // Predefined category styles
    // final Map<String, Map<String, Color>> cat = {
    //   "Personal": {
    //     "color": const Color(0xFF10B981),
    //     "light": const Color(0xFFECFDF5),
    //   },
    //   "School": {
    //     "color": const Color(0xFFEC4899),
    //     "light": const Color(0xFFFDF2F8),
    //   },
    //   "Work": {
    //     "color": const Color(0xFF8B5CF6),
    //     "light": const Color(0xFFF5F3FF),
    //   },
    //   "Company": {
    //     "color": const Color(0xFFF59E0B),
    //     "light": const Color(0xFFFEF3C7),
    //   },
    //   "General": {
    //     "color": const Color(0xFF3B82F6),
    //     "light": const Color(0xFFEFF6FF),
    //   },
    // };

    // Default/fallback colors for unknown categories
    // final Map<String, Color> defaultColors = {
    //   "color": const Color(0xFF6B7280),
    //   "light": const Color(0xFFE5E7EB),
    // };

    //  Normalize incoming category (trim + case-insensitive match)
    // // final normalized = category.trim();
    // // Map<String, Color>? categoryData = cat[normalized];
    // //
    // // if (categoryData == null) {
    // //   // case-insensitive search
    // //   final foundKey = cat.keys.firstWhere(
    // //     (k) => k.toLowerCase() == normalized.toLowerCase(),
    // //     orElse: () => '',
    // //   );
    // //   if (foundKey.isNotEmpty) {
    // //     categoryData = cat[foundKey];
    // //   }
    // // }

    // If still null, use defaultColors (so app never crashes)
    // categoryData = categoryData ?? defaultColors;

    // final accentColor = categoryData["color"]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: getColor(),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStarButton(getColor()),
                ],
              ),

              const SizedBox(height: 10),

              // Body
              Text(
                body,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 14),

              // Footer
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _buildCategoryChip(
                      category.isEmpty ? "Unknown" : category, getColor()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String data, MaterialColor cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cat,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        data,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStarButton(Color accentColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: callback,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            isStar ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isStar ? accentColor : const Color(0xFFD1D5DB),
            size: 22,
          ),
        ),
      ),
    );
  }
}
