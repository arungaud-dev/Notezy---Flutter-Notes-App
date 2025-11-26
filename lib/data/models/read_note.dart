import 'package:notes_app/data/models/note_model.dart';

class NoteWithCategory {
  final String noteID;
  final String noteTitle;
  final String body;
  final String createdAt;
  final int updatedAt;
  final int isStar;
  final int isSynced;
  final String categoryTitle;
  final String categoryColor;

  NoteWithCategory({
    required this.noteID,
    required this.noteTitle,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.isStar,
    required this.isSynced,
    required this.categoryTitle,
    required this.categoryColor,
  });

  // ✅ CopyWith Method
  NoteWithCategory copyWith({
    String? noteID,
    String? noteTitle,
    String? body,
    String? createdAt,
    int? updatedAt,
    int? isStar,
    int? isSynced,
    String? categoryTitle,
    String? categoryColor,
  }) {
    return NoteWithCategory(
      noteID: noteID ?? this.noteID,
      noteTitle: noteTitle ?? this.noteTitle,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isStar: isStar ?? this.isStar,
      isSynced: isSynced ?? this.isSynced,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  factory NoteWithCategory.fromMap(Map<String, dynamic> map) {
    return NoteWithCategory(
      noteID: map['noteID'] as String,
      noteTitle: map['noteTitle'] as String,
      body: map['body'] as String,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'],
      isStar: map['isStar'] as int,
      isSynced: map['isSynced'] as int,
      categoryTitle: map['categoryTitle'] as String,
      categoryColor: map['categoryColor'] as String,
    );
  }

  NoteModel copyWithFor(
      {String? id,
      String? title,
      String? body,
      String? createdAt,
      int? updatedAt,
      int? isStar,
      String? category,
      int? isSynced}) {
    return NoteModel(
        id: id ?? noteID,
        title: title ?? noteTitle,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isStar: isStar ?? this.isStar,
        category: category ?? categoryTitle,
        isSynced: isSynced ?? this.isSynced);
  }

  @override
  String toString() {
    return 'NoteWithCategory(title: $noteTitle, category: $categoryTitle)';
  }
}
