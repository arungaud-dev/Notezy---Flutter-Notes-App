import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/data/models/local_data_model.dart';
import 'package:notes_app/provider/data_provider.dart';

class NoteView extends StatefulWidget {
  final int id;
  final String title;
  final String body;
  final String time;
  final String category;

  const NoteView(
      {super.key,
      required this.id,
      required this.title,
      required this.body,
      required this.time,
      required this.category});

  @override
  State<NoteView> createState() => _NoteAddScreenState();
}

class _NoteAddScreenState extends State<NoteView> {
  final categories = ["Personal", "School", "Work", "Company", "General"];


  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  String? selected = "General";
  int isStar = 0;
  bool confirmation = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _bodyController = TextEditingController(text: widget.body);
  }

  Future<void> showPopUP() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alert"),
            content: Text("Are your sure, You want to delete this note"),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel")),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          confirmation = true;
                          Navigator.pop(context);
                        });
                      },
                      child: Text("Delete"))
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
            return IconButton(
                onPressed: () async {
                      showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Alert"),
                          content: Text(
                              "Are your sure, You want to delete this note"),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel")),
                                ElevatedButton(
                                    onPressed: () async {
                                      await ref
                                          .read(notesProivder.notifier)
                                          .deleteData(widget.id);
                                      confirmation = false;
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Delete"))
                              ],
                            )
                          ],
                        );
                      });
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ));
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
                  // hintText: "Note Title",
                  hintStyle: GoogleFonts.inter(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  Icons.watch_later_outlined,
                  color: Colors.black.withOpacity(0.5),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  widget.time,
                  style: GoogleFonts.inter(
                      color: Colors.black.withOpacity(0.6), fontSize: 16),
                ),
                SizedBox(
                  width: 15,
                ),
                Icon(
                  Icons.folder_open,
                  color: Colors.black.withOpacity(0.5),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  widget.category,
                  style: GoogleFonts.inter(
                      color: Colors.black.withOpacity(0.6), fontSize: 16),
                )
              ],
            ),
            SizedBox(
              height: 18,
            ),
            Expanded(
              child: TextField(
                expands: true,
                minLines: null,
                maxLines: null,
                controller: _bodyController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
