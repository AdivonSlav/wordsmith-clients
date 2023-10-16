import "package:flutter/material.dart";

class InputField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final double width;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? helperText;
  final String? Function(String? value)? validator;

  const InputField({
    super.key,
    required this.labelText,
    required this.controller,
    this.width = 300,
    this.obscureText = false,
    this.suffixIcon,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          hintStyle: theme.inputDecorationTheme.hintStyle,
          suffixIcon: suffixIcon,
          labelText: labelText,
          helperText: helperText,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 5.0,
          ),
        ),
        validator: validator,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
