import 'package:flutter/material.dart';

class SettingsTileButtonWidget extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final void Function()? onTapCallback;

  const SettingsTileButtonWidget(
      {super.key,
      required this.title,
      this.leading,
      this.trailing,
      this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return ListTile(
      title: Text(title),
      titleTextStyle: theme.textTheme.bodyMedium,
      leading: leading,
      trailing: trailing,
      onTap: onTapCallback,
    );
  }
}
