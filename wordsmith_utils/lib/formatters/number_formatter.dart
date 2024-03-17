import 'package:intl/intl.dart';

abstract class NumberFormatter {
  static const String _locale = "en";

  static String formatCurrency(double value) {
    return NumberFormat.currency(locale: _locale, symbol: "\$").format(value);
  }
}
