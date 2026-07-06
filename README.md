# Product Scanner

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-success)

**Product Scanner** is a comprehensive, offline-first mobile application built with Flutter. It is designed to efficiently manage product inventories by utilizing device capabilities like the camera for barcode scanning. All data is persisted locally to ensure uninterrupted access even without an internet connection.

## 📖 About the App & Who It's For

This app is an entirely offline, integrated solution tailored perfectly for **small scale stores**, independent retailers, and warehouse managers. 

It acts as a complete pocket-sized **Product and Inventory Management** system. Store owners and staff can instantly use the **barcode scanner** to pull up product details, check stock levels, and view pricing information on the fly without needing complex software, monthly subscriptions, or an active internet connection.

## 🚀 Key Features

- **Offline-First**: All data is stored locally via Hive, ensuring no dependency on network connectivity.
- **Product Management**: Add, edit, delete, and list products with auto-incrementing tracking.
- **Barcode Integration**: Fast scanning and lookup using the device camera.
- **Dynamic Pricing**: Automatic net price calculation via VAT toggle.
- **Real-Time Dashboard**: Instant searching by product name and code.
- **Data Export**: Export the entire inventory to an `.xlsx` file and share it instantly.
- **Adaptive Theming**: Integrated Light and Dark modes.

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Local Database:** Hive
- **Barcode Scanning:** Mobile Scanner
- **Data Export:** Excel & File Picker

## ⚙️ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio / Xcode

### Installation

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd product_scanner
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 💬 Support

For any inquiries or issues, please reach out to: **support@aflah.xyz**

## 📝 License

This project is licensed under the [MIT License](LICENSE) - Copyright © 2026 Mohd-Aflah.
