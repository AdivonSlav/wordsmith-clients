import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:wordsmith_utils/dialogs.dart";
import "package:wordsmith_utils/models/user.dart";
import "package:wordsmith_utils/models/user_login.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class UserLoginProvider extends BaseProvider<UserLogin> {
  static User? loggedUser;

  UserLoginProvider() : super("users/login");

  @override
  UserLogin fromJson(dynamic data) {
    return UserLogin.fromJson(data);
  }

  Future<UserLogin?> getUserLogin(String username, String password) async {
    Map<String, String> request = {
      "username": username,
      "password": password,
    };

    var result = await post(request: request);

    if (result.accessToken != null && result.refreshToken != null) {
      await storeLogin(loginCreds: result);
      return result;
    } else {
      return null;
    }
  }

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

  Future storeLogin({UserLogin? loginCreds, User? user}) async {
    if (loginCreds != null) {
      String? accessToken = loginCreds.accessToken;
      String? refreshToken = loginCreds.refreshToken;
      int? expiration = loginCreds.expiresIn;

      await SecureStore.writeValue("access_token", accessToken ?? "");
      await SecureStore.writeValue("refresh_token", refreshToken ?? "");
      await SecureStore.writeValue("access_expiration", expiration.toString());

      loggedUser = loginCreds.user;
      notifyListeners();
    } else if (user != null) {
      loggedUser = user;
      notifyListeners();
    }
  }

  Future eraseLogin() async {
    await SecureStore.deleteValue("access_token");
    await SecureStore.deleteValue("refresh_token");
    await SecureStore.deleteValue("access_expiration");

    loggedUser = null;
    notifyListeners();
  }
}
