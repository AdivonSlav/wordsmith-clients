import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/settings_logout.dart';
import 'package:wordsmith_mobile/widgets/settings_theme.dart';

class SettingsScreenWidget extends StatefulWidget {
  const SettingsScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => SettingsScreenWidgetState();
}

class SettingsScreenWidgetState extends State<SettingsScreenWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "Settings",
          style: theme.textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "App Settings",
                style: theme.textTheme.labelSmall,
              ),
            ),
            const Card(
              child: Column(children: <Widget>[
                SettingsThemeWidget(),
              ]),
            ),
            const SizedBox(
              height: 12.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Account Settings",
                style: theme.textTheme.labelSmall,
              ),
            ),
            const Card(
              child: Column(children: <Widget>[
                SettingsLogoutWidget(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
