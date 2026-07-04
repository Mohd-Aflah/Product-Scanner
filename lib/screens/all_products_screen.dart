import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/product_list_tile.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final categories = ref.watch(categoryProvider);

    final filteredProducts = products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.productCode.toString().contains(_searchQuery);
      
      final matchesCategory = _selectedCategory == 'All Categories' ||
          p.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
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
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    filled: true,
                    fillColor: Colors.indigo.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.indigo),
                  items: [
                    const DropdownMenuItem(
                      value: 'All Categories',
                      child: Row(
                        children: [
                          Icon(Icons.list_alt_rounded, size: 20, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text('All Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ...categories
                        .map((c) => c.name)
                        .where((name) => name != 'All Categories')
                        .toSet()
                        .map((name) => DropdownMenuItem(
                          value: name,
                          child: Row(
                            children: [
                              const Icon(Icons.category_rounded, size: 20, color: Colors.indigo),
                              const SizedBox(width: 8),
                              Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductListTile(product: filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
