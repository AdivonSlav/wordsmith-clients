import 'package:flutter/material.dart';
import 'package:wordsmith_utils/dialogs.dart';
import 'package:wordsmith_utils/models/user.dart';
import 'package:wordsmith_utils/models/user_login.dart';
import 'package:wordsmith_utils/secure_store.dart';

class AuthProvider with ChangeNotifier {
  static User? loggedUser;

  Future<String?> getAccessToken(BuildContext context) async {
    var accessToken = await SecureStore.getValue("access_token");

    if (accessToken == null) {
      if (context.mounted) {
        await showErrorDialog(
          context,
          const Text("Error"),
          const Text("Login has timed out"),
        );
      }

      await eraseLogin();
    }

    return accessToken;
  }

  Future<String?> getRefreshToken(BuildContext context) async {
    var refreshToken = await SecureStore.getValue("refresh_token");

    if (refreshToken == null) {
      if (context.mounted) {
        await showErrorDialog(
          context,
          const Text("Error"),
          const Text("Login has timed out"),
        );
      }

      await eraseLogin();
    }

    return refreshToken;
  }

  Future storeLogin(
      {UserLogin? loginCreds, User? user, bool shouldNotify = true}) async {
    if (loginCreds != null) {
      String? accessToken = loginCreds.accessToken;
      String? refreshToken = loginCreds.refreshToken;
      String? expiration = loginCreds.expiresIn?.toIso8601String();
      int id = loginCreds.user.id;

      await SecureStore.writeValue("access_token", accessToken ?? "");
      await SecureStore.writeValue("refresh_token", refreshToken ?? "");
      await SecureStore.writeValue("access_expiration", expiration.toString());
      await SecureStore.writeValue("user_ref_id", id.toString());

      loggedUser = loginCreds.user;
    } else if (user != null) {
      loggedUser = user;
    }

    if (shouldNotify == true) {
      notifyListeners();
    }
  }

  Future eraseLogin() async {
    await SecureStore.deleteValue("access_token");
    await SecureStore.deleteValue("refresh_token");
    await SecureStore.deleteValue("access_expiration");
    await SecureStore.deleteValue("user_ref_id");

    loggedUser = null;
    notifyListeners();
  }
}
