import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/database_service.dart';

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super(DatabaseService.getAllProducts());

  Future<void> addProduct(Product product) async {
    await DatabaseService.addProduct(product);
    refresh();
  }

  Future<void> updateProduct(Product product) async {
    await DatabaseService.updateProduct(product);
    refresh();
  }

  Future<void> deleteProduct(Product product) async {
    await DatabaseService.deleteProduct(product);
    refresh();
  }

  void refresh() {
    state = DatabaseService.getAllProducts();
  }
}
