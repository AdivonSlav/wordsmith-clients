import "package:flutter/material.dart";

Future<dynamic> showErrorDialog(
    BuildContext context, Widget title, Widget content) async {
  if (!context.mounted) return;

  return await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        )
      ],
    ),
  );
}
