import 'package:flutter/material.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_login.dart';
import 'package:wordsmith_utils/secure_store.dart';

class AuthProvider with ChangeNotifier {
  static User? loggedUser;

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
