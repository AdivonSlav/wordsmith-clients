import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/settings/settings_tile_button.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';

class SettingsLogoutWidget extends StatelessWidget {
  const SettingsLogoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.read<AuthProvider>();

    return SettingsTileButtonWidget(
      title: "Logout",
      leading: const Icon(Icons.logout),
      textColor: Colors.red,
      onTapCallback: () async {
        await authProvider.eraseLogin();

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
