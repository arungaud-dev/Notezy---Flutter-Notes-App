import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/home/note_add_screen.dart';
import 'package:notes_app/features/home/note_view.dart';
import 'package:notes_app/provider/data_provider.dart';
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
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesProivder.notifier).getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        // titleSpacing: 0,
        title: Text.rich(TextSpan(
            text: "Notes",
            style: GoogleFonts.inter(
                fontSize: 30,
                color: Colors.green[700],
                fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: " of Arun",
                  style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: Colors.black))
            ])),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.check_circle,
                color: Colors.green[700],
              ))
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          children: [
            Divider(),
            SizedBox(
              height: 15,
            ),
            Consumer(builder: (context, ref, _) {
              final data = ref.watch(notesProivder);
              // return NoteCard(
              //     title: data.isNotEmpty ? data[0].body : "Q4 Planning",
              //     body:
              //         "Discussed project timelines, resource allocation, and key deliverables for the upcoming quarter. Team agreed on...",
              //     isStar: false,
              //     time: "2 hours ago",
              //     category: "Work");
              return Expanded(
                child: data.isEmpty
                    ? Center(
                        child: Text("Data is empty"),
                      )
                    : ListView.builder(
                        itemCount: data.length,
                        // padding: EdgeInsets.symmetric(vertical: 5),
                        itemBuilder: (context, index) {
                          final note = data[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NoteView(
                                          id: note.id!,
                                          title: note.title,
                                          body: note.body,
                                          time: note.createdAt!,
                                          category: note.category)));
                            },
                            child: NoteCard(
                                title: note.title,
                                body: note.body,
                                isStar: note.isStar == 1,
                                time: note.createdAt!,
                                category: note.category),
                          );
                        },
                      ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NoteAddScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
