import "package:intl/date_symbol_data_local.dart";
import "package:intl/intl.dart";

void initializeDateFormattingForLocale() {
  initializeDateFormatting();
}

String formatDateTime({
  required DateTime date,
  required String format,
  String locale = "en",
}) {
  DateTime dateAsUtc = DateTime.parse("$date");

  return DateFormat(format, locale).format(dateAsUtc.toLocal());
}
