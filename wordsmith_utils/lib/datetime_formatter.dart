import "dart:io";
import "package:intl/date_symbol_data_local.dart";
import "package:intl/intl.dart";

void initializeDateFormattingForLocale() {
  initializeDateFormatting();
}

String formatDateTime(
    {required DateTime date, required String format, String? localeName}) {
  DateTime dateAsUtc = DateTime.parse("$date");
  String locale = localeName ?? Platform.localeName;

  return DateFormat(format, locale).format(dateAsUtc.toLocal());
}
