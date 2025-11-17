import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/data/local_data/db_helper.dart';
import 'package:notes_app/data/models/category_model.dart';

final categoryProvider = StateProvider<String?>((ref) => null);

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final List<CategoryModel> defaultData = [
    CategoryModel(id: 0, title: "General"),
    CategoryModel(id: 1, title: "Personal"),
    CategoryModel(id: 2, title: "School")
  ];
  final DBHelper db = DBHelper.instance;
  CategoryNotifier()
      : super([
          CategoryModel(id: 0, title: "General"),
          CategoryModel(id: 1, title: "Personal"),
          CategoryModel(id: 2, title: "School")
        ]);

  Future<void> getCategory() async {
    final data = await db.getCategory();
    state = [...defaultData, ...data];
  }

  Future<void> addCategory(CategoryModel data) async {
    await db.addCategory(data);
    await getCategory();
  }
}

final categoryHandler =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>(
        (ref) => CategoryNotifier());
