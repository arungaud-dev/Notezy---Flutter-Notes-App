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
  String? selectedColor = "green";
  String? selected = "General";
  int isStar = 0;

  final _df = DateFormat('d MMM yyyy', 'en_US');
  String fmtDate(DateTime dt) => _df.format(dt.toLocal());

  final List<Map<String, dynamic>> colors = [
    {"color": Colors.green, "value": "green"},
    {"color": Colors.yellow, "value": "yellow"},
    {"color": Colors.pink, "value": "pink"},
    {"color": Colors.red, "value": "red"},
    {"color": Colors.deepPurple, "value": "purple"},
    {"color": Colors.amber, "value": "amber"},
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _showAddCategorySheet() {
    _categoryController.clear();
    selectedColor = "green";

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setBottomState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      "Add Category",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Name Input
                    Text(
                      "Category Name",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        hintText: "Enter category name",
                        hintStyle: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xFFCBD5E1),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Color Selection
                    Text(
                      "Choose Color",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: colors.map((colorItem) {
                        final Color color = colorItem["color"] as Color;
                        final value = colorItem["value"];
                        final isSelected = selectedColor == value;

                        return GestureDetector(
                          onTap: () {
                            setBottomState(() {
                              selectedColor = value;
                            });
                          },
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                width: isSelected ? 3 : 0,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_categoryController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please enter a category name"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final data = {
                            "title": _categoryController.text.trim(),
                            "color": selectedColor
                          };
                          final check = await ref
                              .read(categoryHandler.notifier)
                              .addCategory(data);

                          if (!context.mounted) return;

                          if (check) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Category added successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to add category"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Add Category",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showManageCategoriesSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final categories = ref.watch(categoryHandler);

            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Manage Categories",
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddCategorySheet();
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Categories List
                    Flexible(
                      child: categories.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      size: 64,
                                      color: Color(0xFFCBD5E1),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No categories yet",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: categories.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                                indent: 24,
                                endIndent: 24,
                              ),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final title = category['title'] ?? '';
                                final colorValue = category['color'] ?? 'green';

                                // Color mapping
                                Color categoryColor = Colors.green;
                                for (var c in colors) {
                                  if (c['value'] == colorValue) {
                                    categoryColor = c['color'] as Color;
                                    break;
                                  }
                                }

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: categoryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  title: Text(
                                    title,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Edit Button
                                      IconButton(
                                        onPressed: () {
                                          // TODO: Edit category logic yahan add karein
                                          // Navigator.pop(context);
                                          // _showEditCategorySheet(category);
                                        },
                                        icon: const Icon(Icons.edit_outlined),
                                        color: const Color(0xFF64748B),
                                        iconSize: 20,
                                      ),
                                      // Delete Button
                                      IconButton(
                                        onPressed: () {
                                          // TODO: Delete category logic yahan add karein
                                          // showDialog(...)
                                        },
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red,
                                        iconSize: 20,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = ref.watch(categoryHandler);

    final uniqueTitles = <String>[];
    for (final cat in categories) {
      final title = (cat['title'] ?? '').toString().trim();
      if (title.isEmpty) continue;
      if (!uniqueTitles.contains(title)) {
        uniqueTitles.add(title);
      }
    }

    if (uniqueTitles.isNotEmpty &&
        (selected == null || !uniqueTitles.contains(selected))) {
      selected = uniqueTitles.first;
    }

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
          // Manage Categories Button
          IconButton(
            onPressed: _showManageCategoriesSheet,
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.category_rounded,
                size: 20,
                color: Color(0xFF475569),
              ),
            ),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),

          // Star Button
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

          // Save Button
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
                      await ref
                          .read(notesProvider.notifier)
                          .addData(data, "Fire Data Provider");
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
                items: uniqueTitles
                    .map((title) => DropdownMenuItem<String>(
                          value: title,
                          child: Text(title),
                        ))
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:notes_app/data/models/note_model.dart';
// import 'package:notes_app/providers/category_provider.dart';
// import 'package:notes_app/providers/notes_provider.dart';
// import 'package:intl/intl.dart';
//
// class NoteAddScreen extends ConsumerStatefulWidget {
//   final String? filter;
//   const NoteAddScreen({super.key, required this.filter});
//
//   @override
//   ConsumerState<NoteAddScreen> createState() => _NoteAddScreenState();
// }
//
// class _NoteAddScreenState extends ConsumerState<NoteAddScreen> {
//   final _categoryController = TextEditingController();
//   final _titleController = TextEditingController();
//   final _bodyController = TextEditingController();
//   String? selectedColor = "green";
//   String? selected = "General";
//   int isStar = 0;
//
//   final _df = DateFormat('d MMM yyyy', 'en_US');
//   String fmtDate(DateTime dt) => _df.format(dt.toLocal());
//
//   final List<Map<String, dynamic>> colors = [
//     {"color": Colors.green as Color, "value": "green"},
//     {"color": Colors.yellow as Color, "value": "yellow"},
//     {"color": Colors.pink as Color, "value": "pink"},
//     {"color": Colors.red as Color, "value": "red"},
//     {"color": Colors.deepPurple as Color, "value": "purple"},
//     {"color": Colors.amber as Color, "value": "amber"},
//   ];
//
//   @override
//   void dispose() {
//     _categoryController.dispose();
//     _titleController.dispose();
//     _bodyController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, dynamic>> categories = ref.watch(categoryHandler);
//
//     /// -- STEP 1: UNIQUE TITLES NIKALO --
//     final uniqueTitles = <String>[];
//     for (final cat in categories) {
//       final title = (cat['title'] ?? '').toString().trim();
//       if (title.isEmpty) continue;
//       if (!uniqueTitles.contains(title)) {
//         uniqueTitles.add(title);
//       }
//     }
//
//     /// -- STEP 2: selected VALUE SHAAMil hai ya nahi --
//     if (uniqueTitles.isNotEmpty &&
//         (selected == null || !uniqueTitles.contains(selected))) {
//       selected = uniqueTitles.first; // Default value daal dena
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         elevation: 0,
//         toolbarHeight: 64,
//         leadingWidth: 64,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 16),
//           child: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF8FAFC),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.close_rounded,
//                 size: 20,
//                 color: Color(0xFF475569),
//               ),
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 showModalBottomSheet(
//                     isDismissible: true,
//                     enableDrag: true,
//                     showDragHandle: true,
//                     context: context,
//                     builder: (context) {
//                       // 1. यहाँ StatefulBuilder जोड़ें
//                       return StatefulBuilder(
//                         builder:
//                             (BuildContext context, StateSetter setBottomState) {
//                           return Container(
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 18, horizontal: 14),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(14),
//                                   topRight: Radius.circular(14)),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize
//                                   .min, // Content के हिसाब से height ले
//                               children: [
//                                 Text(
//                                   "Add Category",
//                                   style: TextStyle(
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 SizedBox(height: 20),
//                                 SizedBox(
//                                   height: 50,
//                                   child: TextField(
//                                     controller:
//                                         _categoryController, // अपना controller यहाँ दें
//                                     decoration: InputDecoration(
//                                         border: OutlineInputBorder(),
//                                         hintText: "Enter category"),
//                                   ),
//                                 ),
//                                 SizedBox(height: 15),
//
//                                 //------------------------------------------ COLORS
//                                 Wrap(
//                                   direction: Axis.horizontal,
//                                   spacing: 5,
//                                   runSpacing: 5,
//                                   children: colors.map((colorItem) {
//                                     // Fix 1: Casting सही की ताकि क्रैश न हो
//                                     final Color color =
//                                         colorItem["color"] as Color;
//                                     final value = colorItem["value"];
//
//                                     return GestureDetector(
//                                       onTap: () {
//                                         // Fix 2: 'setState' की जगह 'setBottomState' यूज़ करें
//                                         setBottomState(() {
//                                           selectedColor = value;
//                                         });
//                                       },
//                                       child: Container(
//                                         height: 60,
//                                         width: 72,
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               width: 3, // थोड़ा मोटा बॉर्डर
//                                               // Fix 3: MaterialColor Check + Visibility Logic
//                                               color: selectedColor == value
//                                                   ? (color is MaterialColor
//                                                       ? color[900]!
//                                                       : Colors.black)
//                                                   : Colors
//                                                       .transparent), // जब select नहीं तो बॉर्डर गायब
//                                           color: color,
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         // Optional: टिक मार्क दिखाएं ताकि यूजर को पक्का पता चले
//                                         child: selectedColor == value
//                                             ? Icon(Icons.check,
//                                                 color: Colors.white)
//                                             : null,
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//
//                                 SizedBox(height: 20),
//                                 SizedBox(
//                                   height: 50,
//                                   child: ElevatedButton.icon(
//                                     onPressed: () async {
//                                       final data = {
//                                         "title":
//                                             _categoryController.text.trim(),
//                                         "color": selectedColor
//                                       };
//                                       final check = await ref
//                                           .read(categoryHandler.notifier)
//                                           .addCategory(data);
//                                       // आपका सेव करने का लॉजिक यहाँ रहेगा...
//                                       if (!context.mounted) return;
//                                       if (check) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(SnackBar(
//                                                 content:
//                                                     Text("Category Added")));
//                                       } else {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(SnackBar(
//                                                 content: Text("Badly Failed")));
//                                       }
//                                       Navigator.pop(context);
//                                     },
//                                     label: Text("Add Category"),
//                                     icon: Icon(Icons.add),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     });
//               },
//               icon: Icon(Icons.category)),
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 isStar = (isStar == 0) ? 1 : 0;
//               });
//             },
//             icon: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: isStar == 1
//                     ? const Color(0xFFFEF3C7)
//                     : const Color(0xFFF8FAFC),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 isStar == 1 ? Icons.star_rounded : Icons.star_outline_rounded,
//                 size: 20,
//                 color: isStar == 1
//                     ? const Color(0xFFF59E0B)
//                     : const Color(0xFF94A3B8),
//               ),
//             ),
//             padding: EdgeInsets.zero,
//           ),
//           const SizedBox(width: 8),
//           Consumer(
//             builder: (context, ref, _) {
//               return Container(
//                 margin: const EdgeInsets.only(right: 16),
//                 child: ElevatedButton.icon(
//                   onPressed: () async {
//                     if (_titleController.text.isNotEmpty ||
//                         _bodyController.text.isNotEmpty) {
//                       final id = DateTime.now().microsecondsSinceEpoch;
//                       final data = NoteModel(
//                         id: id.toString(),
//                         title: _titleController.text,
//                         body: _bodyController.text,
//                         createdAt: fmtDate(DateTime.now()),
//                         category: selected!,
//                         isStar: isStar,
//                         isSynced: 0,
//                         updatedAt: id,
//                       );
//                       await ref
//                           .read(notesProvider.notifier)
//                           .addData(data, "Fire Data Provider");
//                       _titleController.clear();
//                       _bodyController.clear();
//                       if (context.mounted) {
//                         Navigator.pop(context);
//                       }
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 10,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   icon: const Icon(
//                     Icons.check_rounded,
//                     size: 20,
//                     color: Colors.white,
//                   ),
//                   label: Text(
//                     "Save",
//                     style: GoogleFonts.inter(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(
//             height: 1,
//             color: const Color(0xFFF1F5F9),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title Field
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(
//                 hintText: "Note title",
//                 hintStyle: GoogleFonts.inter(
//                   fontSize: 26,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFFCBD5E1),
//                   letterSpacing: -0.8,
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.zero,
//               ),
//               style: GoogleFonts.inter(
//                 fontSize: 26,
//                 fontWeight: FontWeight.w700,
//                 color: const Color(0xFF0F172A),
//                 height: 1.3,
//                 letterSpacing: -0.8,
//               ),
//               maxLines: null,
//             ),
//
//             const SizedBox(height: 24),
//
//             // Category Section
//             Text(
//               "Category",
//               style: GoogleFonts.inter(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF64748B),
//                 letterSpacing: 0.5,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF8FAFC),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: const Color(0xFFE2E8F0),
//                 ),
//               ),
//               child: DropdownButton<String>(
//                 value: selected,
//                 isExpanded: true,
//                 underline: const SizedBox(),
//                 icon: const Icon(
//                   Icons.keyboard_arrow_down_rounded,
//                   color: Color(0xFF64748B),
//                 ),
//                 style: GoogleFonts.inter(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                   color: const Color(0xFF0F172A),
//                 ),
//                 dropdownColor: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 items: uniqueTitles
//                     .map((title) => DropdownMenuItem<String>(
//                           value: title,
//                           child: Text(title),
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selected = value;
//                   });
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Body Field Label
//             Text(
//               "Content",
//               style: GoogleFonts.inter(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF64748B),
//                 letterSpacing: 0.5,
//               ),
//             ),
//             const SizedBox(height: 10),
//
//             // Body Text Field
//             Container(
//               constraints: const BoxConstraints(minHeight: 300),
//               child: TextField(
//                 controller: _bodyController,
//                 maxLines: null,
//                 keyboardType: TextInputType.multiline,
//                 decoration: InputDecoration(
//                   hintText: "Start writing your note...",
//                   hintStyle: GoogleFonts.inter(
//                     fontSize: 16,
//                     color: const Color(0xFFCBD5E1),
//                     height: 1.6,
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.zero,
//                 ),
//                 style: GoogleFonts.inter(
//                   fontSize: 16,
//                   color: const Color(0xFF334155),
//                   height: 1.6,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
