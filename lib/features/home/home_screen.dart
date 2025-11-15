import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/features/home/note_add_screen.dart';
import 'package:notes_app/features/home/note_view.dart';
import 'package:notes_app/features/home/profile_screen.dart';
import 'package:notes_app/provider/category_provider.dart';
import 'package:notes_app/provider/data_provider.dart';
import 'package:notes_app/provider/fire_data_provider.dart';
import 'package:notes_app/widgets/note_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  //--------------------------------------
  final categories = ["Personal", "School", "Work", "Company", "General"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.read(notesProivder.notifier).getData("h1");
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.read(categoryProvider);
    final data = ref.watch(notesProivder);
    ref.watch(fireDataProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text.rich(TextSpan(
            text: "Think",
            style: GoogleFonts.inter(
                fontSize: 30,
                color: Colors.green[700],
                fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: " Notes",
                  style: GoogleFonts.inter(
                      fontSize: 20,
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
      //----------------------------------------------- BODY LAYOUTS --------->>
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          children: [
            Divider(),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 30,
              //FILTER FEATURE  --------------->>>>>>>>>
              child: Row(
                children: [
                  Text("Filter "),
                  PopupMenuButton(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    color: Colors.white,
                    onSelected: (value) {
                      // filter = value;
                      ref.read(categoryProvider.notifier).state = value;
                      // ref.read(notesProivder.notifier).getData("H1");
                      ref.read(notesProivder.notifier).getDataForUi();
                      //
                      // print(
                      //     "------------------------------------------------ Filter s: $filter");
                    },
                    icon: Icon(
                      Icons.filter_list,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                    itemBuilder: (context) {
                      return categories
                          .map((data) =>
                              PopupMenuItem(value: data, child: Text(data)))
                          .toList();
                    },
                  ),
                  filter != null
                      ? GestureDetector(
                          onTap: () {
                            ref.read(categoryProvider.notifier).state = null;
                            // ref.read(notesProivder.notifier).getData("H1");
                            ref.read(notesProivder.notifier).getDataForUi();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                color: Colors.green.withValues(alpha: 0.05)),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    filter,
                                    style: TextStyle(color: Colors.green[700]),
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
              //--------------------------------------------------------------
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
                      // padding: EdgeInsets.symmetric(vertical: 5),
                      itemBuilder: (context, index) {
                        final note = data[index];
                        // debugPrint(
                        //     "---------------SQLITE DATABASE:${note.toMap()}");
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
                              // debugPrint(
                              //     "----------------------------------------------FILTER IS: $filter");
                              ref
                                  .read(notesProivder.notifier)
                                  .updateStar(note.id, filter);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
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
