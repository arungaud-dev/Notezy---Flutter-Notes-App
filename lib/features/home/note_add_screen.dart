import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/data/models/note_model.dart';
import 'package:notes_app/providers/category_provider.dart';
import 'package:notes_app/providers/notes_provider.dart';
import 'package:intl/intl.dart';

class NoteAddScreen extends ConsumerStatefulWidget {
  final String? filter;
  const NoteAddScreen({super.key, required this.filter});

  @override
  ConsumerState<NoteAddScreen> createState() => _NoteAddScreenState();
}

class _NoteAddScreenState extends ConsumerState<NoteAddScreen> {
  final _categoryController = TextEditingController();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? selected = "General";
  int isStar = 0;

  final _df = DateFormat('d MMM yyyy', 'en_US');
  String fmtDate(DateTime dt) => _df.format(dt.toLocal());

  @override
  void dispose() {
    _categoryController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ref.watch(categoryHandler);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isStar = (isStar == 0) ? 1 : 0;
              });
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isStar == 1
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isStar == 1 ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 20,
                color: isStar == 1
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF94A3B8),
              ),
            ),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, _) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty ||
                        _bodyController.text.isNotEmpty) {
                      final id = DateTime.now().microsecondsSinceEpoch;
                      final data = NoteModel(
                        id: id.toString(),
                        title: _titleController.text,
                        body: _bodyController.text,
                        createdAt: fmtDate(DateTime.now()),
                        category: selected!,
                        isStar: isStar,
                        isSynced: 0,
                        updatedAt: id,
                      );
                      await ref.read(notesProvider.notifier).addData(data);
                      _titleController.clear();
                      _bodyController.clear();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Save",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Note title",
                hintStyle: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFCBD5E1),
                  letterSpacing: -0.8,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                height: 1.3,
                letterSpacing: -0.8,
              ),
              maxLines: null,
            ),

            const SizedBox(height: 24),

            // Category Section
            Text(
              "Category",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: DropdownButton<String>(
                value: selected,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                ),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                items: categories
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selected = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Body Field Label
            Text(
              "Content",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // Body Text Field
            Container(
              constraints: const BoxConstraints(minHeight: 300),
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Start writing your note...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFFCBD5E1),
                    height: 1.6,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF334155),
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
