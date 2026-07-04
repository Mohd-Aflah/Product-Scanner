import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/database_service.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(DatabaseService.settings);

  Future<void> toggleTheme(bool isDark) async {
    state.isDarkMode = isDark;
    await DatabaseService.saveSettings();
    state = AppSettings(
      isDarkMode: state.isDarkMode,
      fontSize: state.fontSize,
      lastProductCode: state.lastProductCode,
    );
  }

  Future<void> setFontSize(String size) async {
    state.fontSize = size;
    await DatabaseService.saveSettings();
    state = AppSettings(
      isDarkMode: state.isDarkMode,
      fontSize: state.fontSize,
      lastProductCode: state.lastProductCode,
    );
  }

  void refresh() {
    state = DatabaseService.settings;
  }
}
