import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final String? initialValue;
  final TextEditingController controller;
  final bool obscureText;
  final double? width;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? helperText;
  final String? Function(String? value)? validator;
  final bool? enabled;
  final int? maxLines;
  final int? maxLength;
  final bool? readOnly;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String? value)? onChangedCallback;

  const InputField({
    super.key,
    required this.labelText,
    this.initialValue,
    required this.controller,
    required this.obscureText,
    this.width,
    this.prefixText,
    this.suffixIcon,
    this.helperText,
    this.validator,
    this.enabled,
    this.maxLines,
    this.maxLength,
    this.readOnly,
    this.textInputType,
    this.inputFormatters,
    this.onChangedCallback,
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
        initialValue: initialValue,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
            filled: false,
            fillColor: theme.inputDecorationTheme.fillColor,
            hintStyle: theme.inputDecorationTheme.hintStyle,
            prefixText: prefixText,
            suffixIcon: suffixIcon,
            labelText: labelText,
            helperText: helperText,
            border: const OutlineInputBorder(),
            errorMaxLines: 3,
            contentPadding: const EdgeInsets.all(16.0)),
        validator: validator,
        enabled: enabled,
        maxLines: maxLines,
        maxLength: maxLength,
        readOnly: readOnly ?? false,
        inputFormatters: inputFormatters,
        keyboardType: textInputType,
        onChanged: onChangedCallback,
      ),
    );
  }
}
