class CategoryModel {
  int id;
  String title;
  CategoryModel({required this.id, required this.title});

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(id: map["id"], title: map["title"]);
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "title": title};
  }
}
