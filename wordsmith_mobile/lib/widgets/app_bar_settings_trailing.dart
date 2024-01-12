import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/settings_screen.dart';

class AppBarSettingsTrailingWidget extends StatefulWidget {
  const AppBarSettingsTrailingWidget({super.key});

  @override
  State<StatefulWidget> createState() => AppBarSettingsTrailingWidgetState();
}

class AppBarSettingsTrailingWidgetState
    extends State<AppBarSettingsTrailingWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const SettingsScreenWidget()));
        },
        icon: const Icon(Icons.settings));
  }
}
