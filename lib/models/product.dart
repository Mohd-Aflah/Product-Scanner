import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  int productCode;

  @HiveField(1)
  String? barcode;

  @HiveField(2)
  String name;

  @HiveField(3)
  String category;

  @HiveField(4)
  double purchaseRate;

  @HiveField(5)
  double salesRate;

  @HiveField(6)
  int stock;

  @HiveField(7)
  bool vatEnabled;

  @HiveField(8)
  double netPrice;

  Product({
    required this.productCode,
    this.barcode,
    required this.name,
    required this.category,
    required this.purchaseRate,
    required this.salesRate,
    this.stock = 0,
    this.vatEnabled = false,
    required this.netPrice,
  });
}
