import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../services/database_service.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final Product? productToEdit;
  final String? initialBarcode;

  const AddProductDialog({super.key, this.productToEdit, this.initialBarcode});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _purchaseRateController = TextEditingController();
  final _salesRateController = TextEditingController();
  final _stockController = TextEditingController();
  
  String? _selectedCategory;
  bool _vatEnabled = false;
  double _netPrice = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      _barcodeController.text = widget.productToEdit!.barcode ?? '';
      _purchaseRateController.text = widget.productToEdit!.purchaseRate.toString();
      _salesRateController.text = widget.productToEdit!.salesRate.toString();
      _stockController.text = widget.productToEdit!.stock.toString();
      _selectedCategory = widget.productToEdit!.category;
      _vatEnabled = widget.productToEdit!.vatEnabled;
      _netPrice = widget.productToEdit!.netPrice;
    } else if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  void _calculateNetPrice() {
    double salesRate = double.tryParse(_salesRateController.text) ?? 0.0;
    setState(() {
      if (_vatEnabled) {
        _netPrice = salesRate * 1.05;
      } else {
        _netPrice = salesRate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: bottomPadding + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.productToEdit == null ? 'Add New Product' : 'Edit Product',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (widget.productToEdit != null) ...[
                TextFormField(
                  initialValue: widget.productToEdit!.productCode.toString(),
                  decoration: const InputDecoration(labelText: 'Product Code'),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Barcode (Optional)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.indigo),
                    onPressed: _scanBarcode,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name *'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category *'),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(20),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.indigo),
                isExpanded: true,
                items: [
                  ...categories
                      .map((c) => c.name)
                      .toSet()
                      .map((name) => DropdownMenuItem(
                        value: name,
                        child: Row(
                          children: [
                            const Icon(Icons.category_rounded, size: 20, color: Colors.indigo),
                            const SizedBox(width: 12),
                            Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      )),
                  const DropdownMenuItem(
                    value: 'ADD_NEW',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 20, color: Colors.indigo),
                        SizedBox(width: 12),
                        Text('Add New Category', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val == 'ADD_NEW') {
                    _showAddCategoryDialog();
                  } else {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchaseRateController,
                      decoration: const InputDecoration(labelText: 'Purchase Rate *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salesRateController,
                      decoration: const InputDecoration(labelText: 'Sales Rate *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _calculateNetPrice(),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stock *'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (int.tryParse(val) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 64, // Match text field height approximately
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('VAT', style: TextStyle(fontWeight: FontWeight.bold)),
                          Switch(
                            value: _vatEnabled,
                            onChanged: (val) {
                              setState(() => _vatEnabled = val);
                              _calculateNetPrice();
                            },
                            activeThumbColor: Colors.indigo,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Net Price',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    Text(
                      _netPrice.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.indigo),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: catController,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (catController.text.isNotEmpty) {
                ref.read(categoryProvider.notifier).addCategory(catController.text.trim());
                setState(() {
                  _selectedCategory = catController.text.trim();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (context) => const ScannerPopup(),
    );
    if (barcode != null && barcode.isNotEmpty) {
      setState(() {
        _barcodeController.text = barcode;
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final barcode = _barcodeController.text.trim();
      
      // Check for uniqueness if not editing
      if (barcode.isNotEmpty && widget.productToEdit?.barcode != barcode) {
        final existing = DatabaseService.getProductByBarcode(barcode);
        if (existing != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Barcode already exists!')),
          );
          return;
        }
      }

      final product = Product(
        productCode: widget.productToEdit?.productCode ?? DatabaseService.getNextProductCode(),
        barcode: barcode.isEmpty ? null : barcode,
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        purchaseRate: double.parse(_purchaseRateController.text),
        salesRate: double.parse(_salesRateController.text),
        stock: int.parse(_stockController.text),
        vatEnabled: _vatEnabled,
        netPrice: _netPrice,
      );

      if (widget.productToEdit != null) {
        ref.read(productProvider.notifier).updateProduct(product);
      } else {
        ref.read(productProvider.notifier).addProduct(product);
      }
      Navigator.pop(context);
    }
  }
}

class ScannerPopup extends StatefulWidget {
  const ScannerPopup({super.key});

  @override
  State<ScannerPopup> createState() => _ScannerPopupState();
}

class _ScannerPopupState extends State<ScannerPopup> {
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 300,
        height: 400,
        child: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
                    Navigator.pop(context, code);
                  }
                }
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  color: Colors.white,
                  icon: ValueListenableBuilder(
                    valueListenable: cameraController.torchState,
                    builder: (context, state, child) {
                      switch (state) {
                        case TorchState.on:
                          return const Icon(Icons.flash_on, color: Colors.yellow);
                        case TorchState.off:
                          return const Icon(Icons.flash_off);
                      }
                    },
                  ),
                  iconSize: 24,
                  onPressed: () => cameraController.toggleTorch(),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'Align barcode within frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
