class NoteModel {
  final String id;
  final String title;
  final String body;
  final String? createdAt;
  final int updatedAt;
  final int? isStar;
  final String category;
  final int isSynced;

  NoteModel(
      {required this.id,
      required this.title,
      required this.body,
      this.createdAt,
      required this.updatedAt,
      this.isStar,
      required this.category,
      required this.isSynced});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "body": body,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "isStar": isStar,
      "categoryID": category,
      "isSynced": isSynced
    };
  }

  NoteModel copyWith(
      {String? id,
      String? title,
      String? body,
      String? createdAt,
      int? updatedAt,
      int? isStar,
      String? category,
      int? isSynced}) {
    return NoteModel(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isStar: isStar ?? this.isStar,
        category: category ?? this.category,
        isSynced: isSynced ?? this.isSynced);
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
        id: map["id"].toString(),
        title: map["title"],
        body: map["body"],
        createdAt: map["createdAt"],
        updatedAt: map["updatedAt"],
        isStar: map["isStar"],
        category: map["categoryID"],
        isSynced: map["isSynced"]);
  }
}
