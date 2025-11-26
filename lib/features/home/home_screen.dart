import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/firestore_service/firebase_service.dart';
import 'package:notes_app/features/home/note_add_screen.dart';
import 'package:notes_app/features/home/note_view_screen.dart';
import 'package:notes_app/features/profile/profile_screen.dart';
import 'package:notes_app/providers/category_provider.dart';
import 'package:notes_app/providers/notes_provider.dart';
import 'package:notes_app/providers/fire_data_provider.dart';
import 'package:notes_app/widgets/note_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(categoryHandler.notifier).getCategory();
    // syncCategoryFireToLocal();
  }

  // Future<void> syncCategoryFireToLocal() async {
  //   final firebaseService = ref.read(firebaseServicesProvider);
  //   final category = ref.read(categoryHandler.notifier);
  //   try {
  //     final categories = await firebaseService.getCategoryFromFire();
  //
  //     if (categories.isEmpty) {
  //       debugPrint('syncFirebaseToLocal: no categories to sync');
  //       return;
  //     }
  //
  //     for (var i = 0; i < categories.length; i++) {
  //       final data = categories[i];
  //       try {
  //         final maybeFuture = category.addCategory(data);
  //         await Future.value(maybeFuture);
  //       } catch (e, _) {
  //         debugPrint('(#${i + 1}) CATEGORY Writing FAILED ERROR');
  //       }
  //     }
  //   } catch (e, st) {
  //     debugPrint('syncFirebaseToLocal top-level error: $e\n$st');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(selectedCategoryProvider);
    final data = ref.watch(notesProvider);
    ref.watch(fireDataProvider);
    final List<Map<String, dynamic>> categories = ref.watch(categoryHandler);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 64,
        titleSpacing: 20,
        title: Text(
          "Notes",
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            icon: const Icon(
              Icons.person_outline,
              color: Color(0xFF666666),
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              minimumSize: const Size(40, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 20),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE8E8E8),
          ),
        ),
      ),
      body: data.when(
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            if (categories.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    Text(
                      "Filter by",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        color: Colors.white,
                        elevation: 2,
                        offset: const Offset(0, 8),
                        onSelected: (value) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              value;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filter ?? "All Notes",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Color(0xFF666666),
                            ),
                          ],
                        ),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              value: null,
                              child: Text(
                                "All Notes",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: filter == null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              onTap: () {
                                Future.delayed(Duration.zero, () {
                                  ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state = null;
                                });
                              },
                            ),
                            ...categories.map((data) {
                              return PopupMenuItem(
                                value: data["title"] as String,
                                child: Text(
                                  data["title"],
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: filter == data["title"]
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              );
                            }),
                          ];
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Divider
            Container(
              height: 1,
              color: const Color(0xFFE8E8E8),
            ),

            // Notes Count
            if (data.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  "${data.length} ${data.length == 1 ? 'Note' : 'Notes'}",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.2,
                  ),
                ),
              ),

            // Notes List
            Expanded(
              child: data.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final note = data[index];
                        // debugPrint(
                        //     "-----------CATEGORY: ${note.categoryTitle}, COLOR: ${note.categoryColor}, ID: ${note.noteID}, updatedAT: ${note.updatedAt}");
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteView(
                                  id: note.noteID,
                                  title: note.noteTitle,
                                  body: note.body,
                                  time: note.createdAt,
                                  category: note.categoryTitle,
                                  filter: filter,
                                ),
                              ),
                            );
                          },
                          child: NoteCard(
                            title: note.noteTitle,
                            body: note.body,
                            isStar: note.isStar == 1,
                            time: note.createdAt,
                            category: note.categoryTitle,
                            color: note.categoryColor,
                            callback: () {
                              ref
                                  .read(notesProvider.notifier)
                                  .updateStar(note.noteID);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 72,
                color: Color(0xFFD1D1D1),
              ),
              const SizedBox(height: 20),
              Text(
                "Something went wrong",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF999999),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Retry - provider ko invalidate karo
                  ref.invalidate(notesProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteAddScreen(filter: filter),
            ),
          );
        },
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 72,
            color: const Color(0xFFD1D1D1),
          ),
          const SizedBox(height: 20),
          Text(
            "No notes",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Create your first note",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}
