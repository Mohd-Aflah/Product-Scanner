import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/database_service.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super(DatabaseService.getAllCategories());

  Future<void> addCategory(String name) async {
    await DatabaseService.addCategory(name);
    refresh();
  }

  void refresh() {
    state = DatabaseService.getAllCategories();
  }
}
