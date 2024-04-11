import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class SettingsThemeWidget extends StatefulWidget {
  const SettingsThemeWidget({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsThemeWidgetState();
}

class _SettingsThemeWidgetState extends State<SettingsThemeWidget> {
  late String _currentTheme;

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark) {
      _currentTheme = "Dark";
    } else {
      _currentTheme = "Light";
    }

    return ListTile(
      title: const Text("Theme"),
      leading: const Icon(Icons.brush),
      trailing: Text(_currentTheme),
      onTap: () async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: const Text("Dark"),
                  leading: Radio<String>(
                    value: "Dark",
                    groupValue: _currentTheme,
                    onChanged: (String? value) {
                      setState(() {
                        _currentTheme = "Dark";
                        AdaptiveTheme.of(context).setDark();
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text("Light"),
                  leading: Radio<String>(
                    value: "Light",
                    groupValue: _currentTheme,
                    onChanged: (String? value) {
                      setState(() {
                        _currentTheme = "Light";
                        AdaptiveTheme.of(context).setLight();
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
