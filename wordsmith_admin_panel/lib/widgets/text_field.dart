import "package:flutter/material.dart";

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const TextFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return TextField(
      decoration: const InputDecoration(),
      enabled: false,
      controller: controller,
      maxLines: null,
      style: theme.textTheme.bodyMedium,
    );
  }
}
