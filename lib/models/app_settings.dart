import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  String fontSize; // 'Small', 'Medium', 'Large'

  @HiveField(2)
  int lastProductCode;

  AppSettings({
    this.isDarkMode = false,
    this.fontSize = 'Medium',
    this.lastProductCode = 0,
  });
}
