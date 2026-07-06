# Product Scanner - Mobile Application

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Feature--Driven-success)
![State Management](https://img.shields.io/badge/State%20Management-Riverpod-blue)
![Database](https://img.shields.io/badge/Database-Hive%20Offline-orange)

**Product Scanner** is a comprehensive, offline-first mobile application built with Flutter. It is designed to efficiently manage product inventories by utilizing device capabilities like the camera for barcode scanning. All data is persisted locally to ensure uninterrupted access even without an internet connection. The application emphasizes performance, modularity, and a robust user experience with full support for light and dark themes.
## 🚀 Features

- **Completely Offline**: All data is stored locally via [Hive](https://pub.dev/packages/hive).
- **Product Management**: Add, Edit, Delete, and List products with an Auto-Incrementing Product Code.
- **Barcode Integration**: Fast scanning and lookup using device camera (`mobile_scanner`).
- **Dynamic Pricing**: Automatic Net Price calculation via VAT Toggle switch (5%).
- **Dashboard & Filtering**: Real-time searching by Product Name and Product Code.
- **Excel Export**: Export the entire database into an `.xlsx` file seamlessly.
- **Theming**: Integrated Light/Dark modes & dynamic Font Sizing.

## 🏗 Application Structure
The application code is organized to maximize maintainability, separating concerns across distinct layers:

```text
lib/
├── core/
│   ├── theme.dart          # Light and Dark Material 3 Theme Configurations
│   └── constants.dart      # App-wide constants (Names, Hive Boxes)
├── models/
│   ├── product.dart        # Product Entity (Hive)
│   ├── category.dart       # Category Entity (Hive)
│   └── app_settings.dart   # Local preferences (Dark mode, Font sizes)
├── providers/
│   ├── product_provider.dart  # Riverpod State Notifier for Products
│   ├── category_provider.dart # Riverpod State Notifier for Categories
│   └── settings_provider.dart # Riverpod State Notifier for Settings
├── services/
│   ├── database_service.dart  # Hive box initialization and CRUD Operations
│   └── excel_service.dart     # Handles generating & exporting Excel Files
├── screens/
│   ├── dashboard_screen.dart  # Main Home view (Search, Actions)
│   ├── all_products_screen.dart # List & Filter view
│   └── about_screen.dart      # Details & Developer info
├── widgets/
│   ├── add_product_dialog.dart  # Core Form (Create/Edit Products)
│   ├── product_view_dialog.dart # Read-Only detailed view 
│   ├── product_list_tile.dart   # Row design for Products
│   └── custom_drawer.dart       # Global Navigation & Settings
├── utils/
│   └── formatters.dart     # Currency formatters
└── main.dart               # App Entrypoint
```

## 🛠 Detailed Tech Stack & Tools Used

- **Framework**: [Flutter](https://flutter.dev/) - UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Programming Language**: [Dart](https://dart.dev/) (v3.x)
- **State Management**: [Riverpod (`flutter_riverpod`)](https://pub.dev/packages/flutter_riverpod) - A reactive caching and data-binding framework that provides a robust approach to managing application state and dependency injection.
- **Local Database**: [Hive (`hive`, `hive_flutter`)](https://pub.dev/packages/hive) - A lightweight and blazing fast key-value database written in pure Dart, used here for seamless offline-first capabilities.
- **Barcode & QR Scanning**: [Mobile Scanner (`mobile_scanner`)](https://pub.dev/packages/mobile_scanner) - A universal scanner plugin that accesses the device camera to accurately interpret product barcodes.
- **Data Exporting**: [Excel (`excel`)](https://pub.dev/packages/excel) - Used to generate and write `.xlsx` files, allowing users to export their product database.
- **File System & IO**: 
  - [Path Provider (`path_provider`)](https://pub.dev/packages/path_provider) - Finds commonly used locations on the filesystem.
  - [File Picker (`file_picker`)](https://pub.dev/packages/file_picker) - A package that allows picking and saving files directly from the device's native file explorer.
- **Permissions**: [Permission Handler (`permission_handler`)](https://pub.dev/packages/permission_handler) - A unified API for requesting and checking device permissions (like Camera and Storage access).
- **Date Formatting**: [Intl (`intl`)](https://pub.dev/packages/intl) - Provides internationalization and localization facilities, including date and number formatting.
- **Sharing Capabilities**: [Share Plus (`share_plus`)](https://pub.dev/packages/share_plus) - Used to share the exported Excel files to other apps or services.

## ⚙️ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.x)
- Android Studio / Android SDK (for Android build)
- Xcode (for iOS build)

### Installation

1. Clone or navigate to the repository:
   ```bash
   git clone <repo-url>
   cd product_scanner
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run code generation (for Hive Models):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 🔄 CI/CD & GitHub Actions Integration

This project uses **GitHub Actions** for Continuous Integration and Continuous Deployment (CI/CD).
Whenever a new tag starting with `v` is pushed to the repository (e.g., `v1.0.0`), the CI/CD pipeline will automatically:
1. Setup the Flutter environment.
2. Get the dependencies and run code generation.
3. Build the Android release APK (`app-release.apk`).
4. Create a GitHub Release and upload the APK as a release asset.

To trigger a release manually, run:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## 📱 Troubleshooting Connected Device (Android)

If you have connected your device but `flutter run` or `flutter devices` does not recognize it:
1. **Enable Developer Options**: Go to your Phone Settings -> About Phone -> Tap `Build Number` 7 times.
2. **Enable USB Debugging**: Go to Settings -> System -> Developer Options -> Turn ON `USB Debugging`.
3. **Trust the Computer**: Unplug and re-plug the USB cable. An "Allow USB debugging?" prompt should appear on your phone. Check "Always allow" and tap **OK**.
4. **Change USB Mode**: Ensure your USB configuration is set to **File Transfer (MTP)** or **PTP**, not "Charge Only".

## 💬 Support

- **Email**: support@aflah.xyz

## 📝 License

Copyright © 2026 Mohd-Aflah.
This project is [MIT](LICENSE) licensed.
