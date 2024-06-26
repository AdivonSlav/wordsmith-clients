import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wordsmith_utils/size_config.dart";

class InputField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final double? width;
  final Widget? suffixIcon;
  final String? helperText;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onChanged;
  final bool? enabled;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const InputField({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.width,
    this.suffixIcon,
    this.helperText,
    this.validator,
    this.onChanged,
    this.enabled,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      width: width ?? 350,
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          hintStyle: theme.inputDecorationTheme.hintStyle,
          suffixIcon: suffixIcon,
          labelText: labelText,
          helperText: helperText,
          contentPadding: EdgeInsets.symmetric(
            vertical: SizeConfig.safeBlockVertical * 0.5,
            horizontal: SizeConfig.safeBlockHorizontal * 0.5,
          ),
        ),
        validator: validator,
        style: theme.textTheme.bodyMedium,
        enabled: enabled,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
