import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/data/firestore_service/firebase_service.dart';
import 'package:notes_app/data/models/category_model.dart';
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
  // final categories = ["Personal", "School", "Work", "Company", "General"];
  final _categoryController = TextEditingController();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? selected = "General";
  int isStar = 0;

  // DATE FORMATER-->>>>>>>>>>>>
  final _df = DateFormat('d MMM yyyy', 'en_US');

  String fmtDate(DateTime dt) => _df.format(dt.toLocal());

  @override
  Widget build(BuildContext context) {
    final List<CategoryModel> categories = ref.watch(categoryHandler);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close)),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isStar = (isStar == 0) ? 1 : 0;
                });
              },
              icon: isStar == 0
                  ? Icon(Icons.star_border)
                  : Icon(
                      Icons.star,
                      color: Colors.yellow,
                    )),
          SizedBox(
            width: 8,
          ),
          Consumer(builder: (context, ref, _) {
            return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white),
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
                        updatedAt: id);
                    await ref.read(notesProvider.notifier).addData(data);
                    _titleController.clear();
                    _bodyController.clear();
                  }
                },
                child: Text("Save"));
          }),
          SizedBox(
            width: 18,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Note Title",
                  hintStyle: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 8,
            ),
            Text(
              "Category",
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black.withValues(alpha: 0.06)),
              child: DropdownButton(
                value: selected,
                underline: SizedBox(),
                isExpanded: true,
                // isDense: true,
                items: categories
                    .map((e) =>
                        DropdownMenuItem(value: e.title, child: Text(e.title)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selected = value;
                  });
                },
                dropdownColor: Colors.white,
              ),

              // PopupMenuButton(
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8)),
              //   color: Colors.white,
              //   onSelected: (value) {
              //     ref.read(categoryProvider.notifier).state = value;
              //     ref.read(notesProvider.notifier).getDataForUi();
              //   },
              //   icon: Icon(
              //     Icons.filter_list,
              //     color: Colors.black.withValues(alpha: 0.7),
              //   ),
              //   itemBuilder: (context) {
              //     return categories
              //         .map((data) => PopupMenuItem(
              //         value: data.title,
              //         child: Text(data.title)))
              //         .toList();
              //   },
              // ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Add New Category",
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 50,
                  width: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.category),
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        border: InputBorder.none,
                        hintText: "Enter category name",
                        hintStyle: GoogleFonts.inter(
                            color: Colors.black.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 50,
                  width: 80,
                  child: Consumer(builder: (context, ref, _) {
                    return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white),
                        onPressed: () {
                          final data = CategoryModel(
                              id: DateTime.now().microsecondsSinceEpoch,
                              title: _categoryController.text);
                          ref.read(categoryHandler.notifier).addCategory(data);
                          ref
                              .read(firebaseServicesProvider)
                              .addCategoryInFire(data);
                          _categoryController.clear();
                        },
                        child: Text("Add"));
                  }),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: TextField(
                expands: true,
                minLines: null,
                maxLines: null,
                controller: _bodyController,
                decoration: InputDecoration(
                  hintText: "Start writing your note...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
