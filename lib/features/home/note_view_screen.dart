import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/providers/notes_provider.dart';

class NoteView extends ConsumerStatefulWidget {
  final String id;
  final String title;
  final String body;
  final String time;
  final String category;
  final String? filter;

  const NoteView({
    super.key,
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    required this.filter,
  });

  @override
  ConsumerState<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends ConsumerState<NoteView> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool isChanged = false;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _bodyController = TextEditingController(text: widget.body);
  }

  @override
  void dispose() {
    debounce?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void onTextChange() {
    debounce?.cancel();
    debounce = Timer(const Duration(seconds: 1), () {
      saveAuto();
    });
  }

  Future<void> saveAuto() async {
    if (isChanged) {
      await ref.read(notesProvider.notifier).updateData(
            id: widget.id,
            title: _titleController.text,
            body: _bodyController.text,
            updatedAt: DateTime.now().microsecondsSinceEpoch,
          );
      isChanged = false;
    }
  }

  Future<void> _forceSave() async {
    debounce?.cancel();
    await saveAuto();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    int currentStar = 0;
    notesAsync.whenData((notes) {
      final note = notes.firstWhere(
        (n) => n.id == widget.id,
        orElse: () => notes.first,
      );
      currentStar = note.isStar ?? 0;
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          _forceSave();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          toolbarHeight: 64,
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              onPressed: () async {
                await _forceSave();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF475569),
                ),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                ref.read(notesProvider.notifier).updateStar(widget.id);
              },
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: currentStar == 1
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  currentStar == 1
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 20,
                  color: currentStar == 1
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF94A3B8),
                ),
              ),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showDeleteDialog(context),
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Color(0xFFEF4444),
                ),
              ),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 1,
              color: const Color(0xFFF1F5F9),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    TextField(
                      controller: _titleController,
                      onChanged: (text) {
                        onTextChange();
                        isChanged = true;
                      },
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

                    const SizedBox(height: 16),

                    // Metadata Row
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildMetaChip(
                          Icons.schedule_rounded,
                          widget.time,
                        ),
                        _buildMetaChip(
                          Icons.label_outline_rounded,
                          widget.category,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Body Field
                    TextField(
                      controller: _bodyController,
                      onChanged: (text) {
                        onTextChange();
                        isChanged = true;
                      },
                      decoration: InputDecoration(
                        hintText: "Start writing...",
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
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 28,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Delete Note?",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "This action cannot be undone. The note will be permanently deleted.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await ref
                              .read(notesProvider.notifier)
                              .deleteData(widget.id);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Delete",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
