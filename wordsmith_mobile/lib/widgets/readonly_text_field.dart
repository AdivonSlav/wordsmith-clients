import 'package:flutter/material.dart';

class ReadonlyTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  const ReadonlyTextField(
      {super.key,
      required this.labelText,
      required this.controller,
      required this.minLines,
      required this.maxLines,
      this.maxLength});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 0.0, maxHeight: 400.0),
      child: TextField(
        enabled: true,
        readOnly: true,
        onChanged: null,
        controller: controller,
        textAlign: TextAlign.left,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          filled: true,
          labelText: labelText,
        ),
      ),
    );
  }
}
