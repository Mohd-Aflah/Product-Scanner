import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'services/database_service.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ProductScannerApp()));
}

class ProductScannerApp extends ConsumerStatefulWidget {
  const ProductScannerApp({super.key});

  @override
  ConsumerState<ProductScannerApp> createState() => _ProductScannerAppState();
}

class _ProductScannerAppState extends ConsumerState<ProductScannerApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await DatabaseService.init();
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        title: 'Product Scanner',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    }

    final settings = ref.watch(settingsProvider);
    
    // Determine theme mode
    ThemeMode themeMode = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // Apply font size logic by wrapping with MediaQuery or a Builder
    double fontScale = 1.0;
    if (settings.fontSize == 'Small') fontScale = 0.8;
    if (settings.fontSize == 'Large') fontScale = 1.2;

    return MaterialApp(
      title: 'Product Scanner',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(fontScale),
          ),
          child: child!,
        );
      },
      home: const DashboardScreen(),
    );
  }
}
