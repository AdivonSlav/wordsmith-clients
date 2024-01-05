import 'package:flutter/material.dart';
import 'package:wordsmith_utils/size_config.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final double? width;
  final Widget? suffixIcon;
  final String? helperText;
  final String? Function(String? value)? validator;
  final bool? enabled;

  const InputField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.obscureText,
    this.width,
    this.suffixIcon,
    this.helperText,
    this.validator,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      width: width ?? SizeConfig.safeBlockHorizontal * 80.0,
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          filled: false,
          fillColor: theme.inputDecorationTheme.fillColor,
          hintStyle: theme.inputDecorationTheme.hintStyle,
          suffixIcon: suffixIcon,
          labelText: labelText,
          helperText: helperText,
          border: const OutlineInputBorder(),
          errorMaxLines: 3,
        ),
        validator: validator,
        enabled: enabled,
      ),
    );
  }
}
