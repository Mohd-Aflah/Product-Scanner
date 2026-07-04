import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/product_list_tile.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/product_view_dialog.dart';
import '../services/database_service.dart';
import 'all_products_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    
    final filteredProducts = _searchQuery.isEmpty 
      ? [] 
      : products.where((p) {
          final query = _searchQuery.toLowerCase();
          return p.name.toLowerCase().contains(query) ||
                 p.productCode.toString().contains(query);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Scanner'),
      ),
      drawer: const CustomDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const Text(
                    'Manage Your Products',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Name or Code...',
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.indigo),
                      filled: true,
                      fillColor: Colors.indigo.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Only show grid if not searching
                  if (_searchQuery.isEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            icon: Icons.add_box_rounded,
                            label: 'Add Product',
                            color: Colors.indigo,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => const AddProductDialog(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            icon: Icons.qr_code_scanner_rounded,
                            label: 'Scan Item',
                            color: Colors.cyan.shade700,
                            onTap: () => _scanToFindProduct(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      context,
                      icon: Icons.inventory_2_rounded,
                      label: 'Show All Products',
                      color: Colors.teal,
                      isWide: true,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AllProductsScreen()));
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Additions',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AllProductsScreen()));
                          },
                          child: const Text('See All'),
                        )
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Search Results or Recent
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final list = _searchQuery.isNotEmpty 
                      ? filteredProducts 
                      : products.reversed.take(5).toList();
                      
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No products found.', style: TextStyle(color: Colors.grey))),
                    );
                  }
                  return ProductListTile(product: list[index]);
                },
                childCount: _searchQuery.isNotEmpty 
                    ? (filteredProducts.isEmpty ? 1 : filteredProducts.length)
                    : (products.isEmpty ? 1 : (products.length > 5 ? 5 : products.length)),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap, bool isWide = false}) {
    return Container(
      height: isWide ? 100 : 140,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isWide 
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Text(label, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    Text(label, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  Future<void> _scanToFindProduct(BuildContext context) async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (context) => const ScannerPopup(),
    );
    if (barcode != null && barcode.isNotEmpty && context.mounted) {
      final product = DatabaseService.getProductByBarcode(barcode);
      if (product != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => ProductViewDialog(product: product),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Product Not Found'),
            content: Text('No product found with barcode:\n$barcode'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }
}
