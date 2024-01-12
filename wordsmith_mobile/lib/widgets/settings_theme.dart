import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/settings_tile_button.dart';

class SettingsThemeWidget extends StatefulWidget {
  const SettingsThemeWidget({super.key});

  @override
  State<StatefulWidget> createState() => SettingsThemeWidgetState();
}

class SettingsThemeWidgetState extends State<SettingsThemeWidget> {
  late String _currentTheme;

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark) {
      _currentTheme = "Dark";
    } else {
      _currentTheme = "Light";
    }

    return SettingsTileButtonWidget(
      title: "Theme",
      leading: const Icon(Icons.brush),
      trailing: Text(_currentTheme),
      onTapCallback: () async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SettingsTileButtonWidget(
                  title: "Dark",
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
                SettingsTileButtonWidget(
                  title: "Light",
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
