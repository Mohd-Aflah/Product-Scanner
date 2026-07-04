import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currencyFormatter = NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
  );

  static String formatPrice(double price) {
    return currencyFormatter.format(price);
  }
}
