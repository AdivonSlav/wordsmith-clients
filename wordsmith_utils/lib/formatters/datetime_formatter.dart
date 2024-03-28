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
  return DateFormat(format, locale).format(date.toLocal());
}

String timeAgoSinceDate({required DateTime date, bool numericDates = true}) {
  DateTime asLocal = date.toLocal();
  DateTime now = DateTime.now().toLocal();
  final Duration difference = now.difference(asLocal);

  if (difference.inSeconds < 5) {
    return 'Just now';
  } else if (difference.inSeconds < 60) {
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inMinutes < 60) {
    return (numericDates && difference.inMinutes == 1)
        ? '1 minute ago'
        : '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return (numericDates && difference.inHours == 1)
        ? '1 hour ago'
        : '${difference.inHours} hours ago';
  } else if (difference.inDays == 1) {
    return (numericDates) ? '1 day ago' : 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 14) {
    return (numericDates) ? '1 week ago' : 'Last week';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).ceil()} weeks ago';
  } else if (difference.inDays < 60) {
    return (numericDates) ? '1 month ago' : 'Last month';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).ceil()} months ago';
  } else if (difference.inDays < 730) {
    return (numericDates) ? '1 year ago' : 'Last year';
  }

  return '${(difference.inDays / 365).floor()} years ago';
}
