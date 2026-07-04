import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/app_settings.dart';
import '../core/constants.dart';

class DatabaseService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    await Hive.openBox<Product>(AppConstants.productBox);
    await Hive.openBox<Category>(AppConstants.categoryBox);
    await Hive.openBox<AppSettings>(AppConstants.settingsBox);

    // Initialize AppSettings if empty
    var settingsBox = Hive.box<AppSettings>(AppConstants.settingsBox);
    if (settingsBox.isEmpty) {
      await settingsBox.add(AppSettings());
    }

    // Seed default categories for Electric Shop
    var catBox = Hive.box<Category>(AppConstants.categoryBox);
    final defaultCategories = [
      'Lighting & Bulbs',
      'Cables & Wires',
      'Switches & Sockets',
      'Tools & Equipment',
      'Breakers & Panels',
      'Conduits & Fittings',
      'Other'
    ];
    
    for (var cat in defaultCategories) {
      bool exists = catBox.values.any((c) => c.name.toLowerCase() == cat.toLowerCase());
      if (!exists) {
        await catBox.add(Category(name: cat));
      }
    }
  }

  static Box<Product> get productsBox => Hive.box<Product>(AppConstants.productBox);
  static Box<Category> get categoriesBox => Hive.box<Category>(AppConstants.categoryBox);
  static Box<AppSettings> get settingsBox => Hive.box<AppSettings>(AppConstants.settingsBox);

  // Settings
  static AppSettings get settings => settingsBox.getAt(0)!;
  static Future<void> saveSettings() async {
    await settings.save();
  }

  static int getNextProductCode() {
    int currentCode = settings.lastProductCode;
    settings.lastProductCode = currentCode + 1;
    settings.save();
    return settings.lastProductCode;
  }

  // Products
  static List<Product> getAllProducts() {
    return productsBox.values.toList();
  }

  static Future<void> addProduct(Product product) async {
    await productsBox.add(product);
  }

  static Future<void> updateProduct(Product product) async {
    await product.save();
  }

  static Future<void> deleteProduct(Product product) async {
    await product.delete();
  }

  static Product? getProductByBarcode(String barcode) {
    if (barcode.isEmpty) return null;
    try {
      return productsBox.values.firstWhere((p) => p.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  // Categories
  static List<Category> getAllCategories() {
    return categoriesBox.values.toList();
  }

  static Future<void> addCategory(String name) async {
    bool exists = categoriesBox.values.any((c) => c.name.toLowerCase() == name.toLowerCase());
    if (!exists) {
      await categoriesBox.add(Category(name: name));
    }
  }

  static Future<void> clearAllData() async {
    await productsBox.clear();
    await categoriesBox.clear();
    settings.lastProductCode = 0;
    await settings.save();
  }
}
