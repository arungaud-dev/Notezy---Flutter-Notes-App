import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/firestore_service/firebase_service.dart';
import 'package:notes_app/data/models/category_model.dart';
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
    ref.read(notesProvider.notifier).getData("h1");
    ref.read(categoryHandler.notifier).getCategory();
    syncCategoryFireToLocal();
  }

  Future<void> syncCategoryFireToLocal() async {
    final firebaseService = ref.read(firebaseServicesProvider);
    final category = ref.read(categoryHandler.notifier);
    try {
      // use FirebaseAuth directly to log uid (safe)
      // final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      // debugPrint('syncFirebaseToLocal: firebaseUid=$firebaseUid');

      // Use the captured firebaseService (not ref.read inside here)
      final categories = await firebaseService.getCategoryFromFire();

      if (categories.isEmpty) {
        debugPrint('syncFirebaseToLocal: no categories to sync');
        return;
      }

      for (var i = 0; i < categories.length; i++) {
        final data = categories[i];
        try {
          // call notifier (notifier was captured earlier)
          final maybeFuture = category.addCategory(data);
          await Future.value(maybeFuture); // handles void or Future
        } catch (e, st) {
          debugPrint(
              '(#${i + 1}) CATEGORY Writing FAILED for ${data.title}: $e\n$st');
        }
      }
    } catch (e, st) {
      debugPrint('syncFirebaseToLocal top-level error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.read(categoryProvider);
    final data = ref.watch(notesProvider);
    ref.watch(fireDataProvider);
    final List<CategoryModel> categories = ref.watch(categoryHandler);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text.rich(TextSpan(
            text: "Notezy",
            style: GoogleFonts.inter(
                fontSize: 30,
                color: Colors.green[700],
                fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: " Notes",
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontStyle: FontStyle.italic))
            ])),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1,
                    color: Colors.green[700]!,
                  )),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[700],
              ),
            ),
          ),
          SizedBox(
            width: 18,
          )
        ],
      ),
      //----------------- BODY LAYOUTS --------->>
      backgroundColor: Colors.white,
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: isLoading == false
              ? Column(
                  children: [
                    Divider(),
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 30,
                      //FILTER FEATURE  >>>>>>>>>
                      child: Row(
                        children: [
                          Text(
                            "Filter ",
                            style: GoogleFonts.inter(fontSize: 16),
                          ),
                          PopupMenuButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            color: Colors.white,
                            onSelected: (value) {
                              ref.read(categoryProvider.notifier).state = value;
                              ref.read(notesProvider.notifier).getDataForUi();
                            },
                            icon: Icon(
                              Icons.filter_list,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                            itemBuilder: (context) {
                              return categories
                                  .map((data) => PopupMenuItem(
                                      value: data.title,
                                      child: Text(data.title)))
                                  .toList();
                            },
                          ),
                          filter != null
                              ? GestureDetector(
                                  onTap: () {
                                    ref.read(categoryProvider.notifier).state =
                                        null;
                                    ref
                                        .read(notesProvider.notifier)
                                        .getDataForUi();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        color: Colors.green
                                            .withValues(alpha: 0.05)),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            filter,
                                            style: TextStyle(
                                                color: Colors.green[700]),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Icon(
                                            Icons.clear,
                                            color: Colors.green[700],
                                            size: 18,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: data.isEmpty
                          ? Center(
                              child: Text("Data is empty"),
                            )
                          : ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final note = data[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => NoteView(
                                                  id: note.id,
                                                  title: note.title,
                                                  body: note.body,
                                                  time: note.createdAt!,
                                                  category: note.category,
                                                  filter: filter,
                                                )));
                                  },
                                  child: NoteCard(
                                    title: note.title,
                                    body: note.body,
                                    isStar: note.isStar == 1,
                                    time: note.createdAt!,
                                    category: note.category,
                                    callback: () {
                                      ref
                                          .read(notesProvider.notifier)
                                          .updateStar(note.id);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NoteAddScreen(
                        filter: filter,
                      )));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
