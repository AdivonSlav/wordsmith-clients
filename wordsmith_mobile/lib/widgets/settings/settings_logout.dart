import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/indexers/ebook_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/user_index_provider.dart';
import 'package:wordsmith_mobile/widgets/settings/settings_tile_button.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';

class SettingsLogoutWidget extends StatefulWidget {
  const SettingsLogoutWidget({super.key});

  @override
  State<SettingsLogoutWidget> createState() => _SettingsLogoutWidgetState();
}

class _SettingsLogoutWidgetState extends State<SettingsLogoutWidget> {
  final _logger = LogManager.getLogger("SettingsLogoutWidget");
  late AuthProvider _authProvider;
  late EbookIndexProvider _ebookIndexProvider;
  late UserIndexProvider _userIndexProvider;

  Future<void> _logout() async {
    bool purgedEbookIndex =
        await _ebookIndexProvider.removeAll().then((result) {
      switch (result) {
        case Success():
          return true;
        case Failure<String>():
          return false;
      }
    });

    bool purgedUserIndex =
        await _userIndexProvider.removeFromIndex().then((result) {
      switch (result) {
        case Success<String>():
          return true;
        case Failure<String>():
          return false;
      }
    });

    if (!purgedEbookIndex) {
      _logger.warning("Was not able to purge ebook index!");
    }

    if (!purgedUserIndex) {
      _logger.warning("Was not able to purge user index!");
    }

    await _authProvider.eraseLogin().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _ebookIndexProvider = Provider.of<EbookIndexProvider>(context);
    _userIndexProvider = Provider.of<UserIndexProvider>(context);

    return SettingsTileButtonWidget(
      title: "Logout",
      leading: const Icon(Icons.logout),
      textColor: Colors.red,
      onTapCallback: _logout,
    );
  }
}
