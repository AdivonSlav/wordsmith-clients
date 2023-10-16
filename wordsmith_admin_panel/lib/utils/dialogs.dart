import "package:flutter/material.dart";

showErrorDialog(BuildContext context, Widget title, Widget content) {
  if (!context.mounted) return;

  showDialog(
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
