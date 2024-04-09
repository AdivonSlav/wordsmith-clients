import 'package:flutter/material.dart';

/// Shows a snackbar in the current context with the provided content
///
/// Parameters:
/// - [context]: The build context of the widget showing the snackbar. If it is not mounted, nothing will be shown
/// - [content]: The text content of the snackbar
/// - [behaviour]: Snackbar positioning behaviour. By default it is set to floating
void showSnackbar({
  required BuildContext context,
  required String content,
  SnackBarBehavior behaviour = SnackBarBehavior.floating,
  Color? backgroundColor,
}) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: behaviour,
      content: Text(content),
      backgroundColor: backgroundColor,
    ));
  }
}
