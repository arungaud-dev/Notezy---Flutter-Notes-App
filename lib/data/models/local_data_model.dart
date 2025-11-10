class DataModel {
  final int? id;
  final String title;
  final String body;
  final String? createdAt;
  final String? updatedAt;
  final int? isStar;
  final String category;

  DataModel(
      {this.id,
      required this.title,
      required this.body,
      this.createdAt,
      this.updatedAt,
      this.isStar,
      required this.category});

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "body": body,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "isStar": isStar,
      "category": category
    };
  }

  DataModel copyWith(
      {int? id,
      String? title,
      String? body,
      String? createdAt,
      String? updatedAt,
      int? isStar,
      String? category}) {
    return DataModel(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isStar: isStar ?? this.isStar,
        category: category ?? this.category);
  }

  factory DataModel.fromMap(Map<String, dynamic> map) {
    return DataModel(
        id: map["id"],
        title: map["title"],
        body: map["body"],
        createdAt: map["createdAt"],
        updatedAt: map["updatedAt"],
        isStar: map["isStar"],
        category: map["category"]);
  }
}
