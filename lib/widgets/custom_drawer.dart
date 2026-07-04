import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/product_provider.dart';
import '../services/database_service.dart';
import '../services/excel_service.dart';
import '../screens/about_screen.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final products = ref.watch(productProvider);
    
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.indigo.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/icon.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Product Scanner',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(
              context,
              icon: Icons.file_download_outlined,
              title: 'Export Data to Excel',
              onTap: () async {
                Navigator.pop(context);
                if (products.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No products to export')),
                  );
                  return;
                }
                bool success = await ExcelService.exportProducts(products);
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export ready to share')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to export. Permission denied or error occurred.')),
                  );
                }
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.file_upload_outlined,
              title: 'Import Data from Excel',
              onTap: () async {
                Navigator.pop(context);
                int count = await ExcelService.importProducts(ref);
                if (!context.mounted) return;
                if (count > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $count products successfully!')));
                } else if (count == 0) {
                  // User canceled
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to import products.')));
                }
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.delete_forever_rounded,
              title: 'Clear All Data',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showClearDataConfirmation(context, ref);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SwitchListTile(
                title: const Text('Dark Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.dark_mode_rounded, color: Theme.of(context).iconTheme.color),
                ),
                value: settings.isDarkMode,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                activeTrackColor: Colors.indigo.withValues(alpha: 0.5),
                activeThumbColor: Colors.indigo,
                onChanged: (val) {
                  settingsNotifier.toggleTheme(val);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.format_size_rounded, color: Theme.of(context).iconTheme.color),
                ),
                title: const Text('Font Size', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: settings.fontSize,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.indigo),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    items: ['Small', 'Medium', 'Large']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        settingsNotifier.setFontSize(val);
                      }
                    },
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(height: 1),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? iconColor, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.indigo).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? Theme.of(context).iconTheme.color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        onTap: onTap,
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to delete all products, categories, and reset the product code? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.clearAllData();
              ref.read(productProvider.notifier).refresh();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
