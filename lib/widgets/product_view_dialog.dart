import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/formatters.dart';

class ProductViewDialog extends ConsumerStatefulWidget {
  final Product product;
  const ProductViewDialog({super.key, required this.product});

  @override
  ConsumerState<ProductViewDialog> createState() => _ProductViewDialogState();
}

class _ProductViewDialogState extends ConsumerState<ProductViewDialog> {
  late Product product;

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  void _updateStock(int change) {
    if (product.stock + change < 0) return;
    setState(() {
      product.stock += change;
    });
    ref.read(productProvider.notifier).updateProduct(product);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
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
            product.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildRow('Product Code', product.productCode.toString()),
                const Divider(height: 24),
                _buildRow('Barcode', product.barcode?.isEmpty ?? true ? 'N/A' : product.barcode!),
                const Divider(height: 24),
                _buildRow('Category', product.category),
                const Divider(height: 24),
                _buildRow('Purchase Rate', Formatters.formatPrice(product.purchaseRate)),
                const Divider(height: 24),
                _buildRow('Sales Rate', Formatters.formatPrice(product.salesRate)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Stock', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _updateStock(-1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        Text(product.stock.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: () => _updateStock(1),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildRow('VAT Enabled', product.vatEnabled ? 'Yes (5%)' : 'No'),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                Text(
                  Formatters.formatPrice(product.netPrice),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.indigo),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.pop(context, 'edit');
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.red,
                ),
                onPressed: () {
                  _showDeleteConfirmation(context, ref);
                },
                child: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext parentContext, WidgetRef ref) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(productProvider.notifier).deleteProduct(product);
              Navigator.pop(context); // Close confirmation
              Navigator.pop(parentContext); // Close bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
