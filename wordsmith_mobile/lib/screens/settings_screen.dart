import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/profile/edit_password_dialog.dart';
import 'package:wordsmith_mobile/widgets/report/app_report_dialog.dart';
import 'package:wordsmith_mobile/widgets/settings/settings_logout.dart';
import 'package:wordsmith_mobile/widgets/settings/settings_theme.dart';

class SettingsScreenWidget extends StatefulWidget {
  const SettingsScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenWidgetState();
}

class _SettingsScreenWidgetState extends State<SettingsScreenWidget> {
  final _labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 11.0,
  );

  Widget _buildAppSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "App Settings",
            style: _labelStyle,
          ),
        ),
        const Card(
          child: SettingsThemeWidget(),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Account Settings",
            style: _labelStyle,
          ),
        ),
        Card(
          child: ListTile(
            title: const Text("Change password"),
            leading: const Icon(Icons.password),
            onTap: () => _openChangePasswordDialog(),
          ),
        ),
        const Card(
          child: SettingsLogoutWidget(),
        ),
      ],
    );
  }

  Widget _buildMoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "More",
            style: _labelStyle,
          ),
        ),
        Card(
          child: ListTile(
            title: const Text("Report"),
            leading: const Icon(Icons.report),
            subtitle: const Text("File a report for an app issue"),
            onTap: () => _openAppReportDialog(),
          ),
        ),
      ],
    );
  }

  void _openChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const EditPasswordDialogWidget(),
    );
  }

  void _openAppReportDialog() {
    showDialog(
      context: context,
      builder: (context) => const AppReportDialogWidget(),
    );
  }

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
            Builder(builder: (context) => _buildAppSettings()),
            const SizedBox(height: 12.0),
            Builder(builder: (context) => _buildAccountSettings()),
            const SizedBox(height: 12.0),
            Builder(builder: (context) => _buildMoreSection()),
          ],
        ),
      ),
    );
  }
}
