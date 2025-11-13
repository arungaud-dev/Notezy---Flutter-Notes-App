import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/provider/data_provider.dart';
import 'package:notes_app/provider/fire_data_provider.dart';

class NoteView extends ConsumerStatefulWidget {
  final String id;
  final String title;
  final String body;
  final String time;
  final String category;
  final String? filter;

  const NoteView(
      {super.key,
      required this.id,
      required this.title,
      required this.body,
      required this.time,
      required this.category,
      required this.filter});

  @override
  ConsumerState<NoteView> createState() => _NoteAddScreenState();
}

class _NoteAddScreenState extends ConsumerState<NoteView> {
  final categories = ["Personal", "School", "Work", "Company", "General"];

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  Timer? debounce;
  String? selected = "General";
  // int isStar = 0;
  bool confirmation = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _bodyController = TextEditingController(text: widget.body);
  }

  @override
  void dispose() {
    debounce?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  void onTextChange() {
    debounce?.cancel();
    debounce = Timer(Duration(seconds: 1), () {
      saveAuto();
    });
  }

  Future<void> saveAuto() async {
    await ref.read(notesProivder.notifier).updateData(
        widget.id,
        _titleController.text,
        _bodyController.text,
        widget.filter,
        DateTime.now().microsecondsSinceEpoch);
  }

  Future<void> _forceSave() async {
    debounce?.cancel();
    await saveAuto();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(notesProivder);
    final filtered = data.where((data) => data.id == widget.id);
    // ref.watch(dataProvider)

    if (filtered.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(), // या कुछ भी
        ),
      );
    }

    final star = filtered.first;

    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            _forceSave();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: IconButton(
                onPressed: () async {
                  await _forceSave();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(Icons.close)),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      // isStar = (isStar == 0) ? 1 : 0;
                      ref
                          .read(notesProivder.notifier)
                          .updateStar(widget.id, widget.filter);
                    });
                  },
                  icon: star.isStar == 0
                      ? Icon(Icons.star_border)
                      : Icon(
                          Icons.star,
                          color: Colors.yellow,
                        )),
              SizedBox(
                width: 8,
              ),
              IconButton(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            .deleteData(
                                                widget.id, widget.filter);

                                        if (!context.mounted) return;
                                        confirmation = false;
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
                  )),
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
                    onChanged: (text) {
                      onTextChange();
                      debugPrint(
                          "---------------------------------TEXT ON CHANGE: $text");
                    },
                    decoration: InputDecoration(
                      hintStyle: GoogleFonts.inter(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withValues(alpha: 0.5)),
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
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.time,
                      style: GoogleFonts.inter(
                          color: Colors.black.withValues(alpha: 0.5),
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Icon(
                      Icons.folder_open,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.category,
                      style: GoogleFonts.inter(
                          color: Colors.black.withValues(alpha: 0.5),
                          fontSize: 16),
                    )
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                Expanded(
                  child: TextField(
                    onChanged: (text) {
                      onTextChange();
                    },
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
        ));
  }
}
