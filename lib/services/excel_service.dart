import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';

class ExcelService {
  static Future<bool> exportProducts(List<Product> products) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Products'];
      excel.setDefaultSheet('Products');

      // Add Headers
      sheetObject.appendRow([
        TextCellValue('Product Code'),
        TextCellValue('Barcode'),
        TextCellValue('Product Name'),
        TextCellValue('Category'),
        TextCellValue('Purchase Rate'),
        TextCellValue('Sales Rate'),
        TextCellValue('Stock'),
        TextCellValue('VAT Enabled'),
        TextCellValue('Net Sales Rate'),
      ]);

      // Add Data
      for (var product in products) {
        sheetObject.appendRow([
          IntCellValue(product.productCode),
          TextCellValue(product.barcode ?? ''),
          TextCellValue(product.name),
          TextCellValue(product.category),
          DoubleCellValue(product.purchaseRate),
          DoubleCellValue(product.salesRate),
          IntCellValue(product.stock),
          TextCellValue(product.vatEnabled ? 'Yes' : 'No'),
          DoubleCellValue(product.netPrice),
        ]);
      }

      String dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      String fileName = 'ProductScan_Products_$dateStr.xlsx';

      final tempDir = await getTemporaryDirectory();
      File file = File('${tempDir.path}/$fileName');
      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      final xfile = XFile(file.path);
      await Share.shareXFiles([xfile], text: 'Exported Products Data');
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<int> importProducts(WidgetRef ref) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.single.path == null) {
        return 0; // User canceled
      }

      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      int count = 0;
      final productNotifier = ref.read(productProvider.notifier);
      final categoryNotifier = ref.read(categoryProvider.notifier);

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table]!;
        for (int i = 1; i < sheet.maxRows; i++) {
          var row = sheet.row(i);
          if (row.isEmpty) continue;
          
          String name = row[2]?.value?.toString() ?? '';
          if (name.isEmpty) continue;

          String? barcode = row[1]?.value?.toString();
          if (barcode == 'null' || barcode == null || barcode.isEmpty) barcode = null;
          
          String category = row[3]?.value?.toString() ?? 'Other';
          
          double purchaseRate = 0.0;
          if (row[4] != null && row[4]!.value != null) {
             purchaseRate = double.tryParse(row[4]!.value.toString()) ?? 0.0;
          }
          
          double salesRate = 0.0;
          if (row[5] != null && row[5]!.value != null) {
             salesRate = double.tryParse(row[5]!.value.toString()) ?? 0.0;
          }
          
          int stock = 0;
          if (row[6] != null && row[6]!.value != null) {
             stock = int.tryParse(row[6]!.value.toString()) ?? 0;
          }
          
          bool vatEnabled = row[7]?.value?.toString().toLowerCase() == 'yes';
          
          double netPrice = salesRate;
          if (row[8] != null && row[8]!.value != null) {
             netPrice = double.tryParse(row[8]!.value.toString()) ?? salesRate;
          }
          
          // Ensure category exists
          categoryNotifier.addCategory(category);
          
          int code = 0;
          if (row[0] != null && row[0]!.value != null) {
             code = int.tryParse(row[0]!.value.toString()) ?? DatabaseService.getNextProductCode();
          } else {
             code = DatabaseService.getNextProductCode();
          }

          Product? existingProduct;
          try {
             existingProduct = DatabaseService.productsBox.values.firstWhere((p) => p.productCode == code || (barcode != null && p.barcode == barcode));
          } catch (e) {
             existingProduct = null;
          }

          if (existingProduct != null) {
            existingProduct.name = name;
            existingProduct.category = category;
            existingProduct.purchaseRate = purchaseRate;
            existingProduct.salesRate = salesRate;
            existingProduct.stock = stock;
            existingProduct.vatEnabled = vatEnabled;
            existingProduct.netPrice = netPrice;
            if (barcode != null) existingProduct.barcode = barcode;
            await productNotifier.updateProduct(existingProduct);
          } else {
            await productNotifier.addProduct(Product(
              productCode: code,
              name: name,
              barcode: barcode,
              category: category,
              purchaseRate: purchaseRate,
              salesRate: salesRate,
              stock: stock,
              vatEnabled: vatEnabled,
              netPrice: netPrice,
            ));
          }
          count++;
        }
      }
      return count;
    } catch (e) {
      return -1;
    }
  }
}
