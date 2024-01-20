import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:wordsmith_utils/dialogs.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/user.dart";
import "package:wordsmith_utils/models/user_login.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class UserLoginProvider extends BaseProvider<UserLogin> {
  static User? loggedUser;
  final _logger = LogManager.getLogger("UserLoginProvider");

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

  Future validateUserLogin() async {
    var accessToken = await SecureStore.getValue("access_token");
    var refreshToken = await SecureStore.getValue("refresh_token");
    var expiration = await SecureStore.getValue("access_expiration");
    var id = await SecureStore.getValue("user_ref_id");

    // If any values are not found within SecureStore, terminate the user session
    if (accessToken == null ||
        refreshToken == null ||
        expiration == null ||
        id == null) {
      await eraseLogin();
      return;
    }

    var currentDate = DateTime.now().toUtc();
    var expirationDate = DateTime.parse(expiration).toUtc();
    var shouldAttemptRefresh = false;
    UserLogin? userLogin;

    // If the access token has not expired expired, also proceed to check whether the access token is still valid
    // If valid, we get the current login
    if (currentDate.isBefore(expirationDate)) {
      userLogin = await _verifyUserLogin(accessToken, id);

      if (userLogin == null) {
        shouldAttemptRefresh = true;
      }
    } else {
      // If the token is expired, immediately try to perform a refresh attempt
      shouldAttemptRefresh = true;
    }

    if (shouldAttemptRefresh == true) {
      _logger.info("Attempting to refresh login session...");
      var refreshedCreds = await _refreshUserLogin(refreshToken, id);

      if (refreshedCreds != null) {
        _logger.info("Succesfully refreshed login session");
        await storeLogin(loginCreds: refreshedCreds);
        return;
      } else {
        await eraseLogin();
        return;
      }
    }

    // If the access token is valid and we got a login back from verification, store it and notify listeners
    if (userLogin != null) {
      await storeLogin(user: userLogin.user);
    }

    return true;
  }

  Future<UserLogin?> _refreshUserLogin(String refreshToken, String id) async {
    Map<String, String> query = {"id": id};

    try {
      var result = await get(
          filter: query,
          additionalRoute: "/refresh",
          bearerToken: refreshToken);

      if (result.result[0].accessToken != null &&
          result.result[0].refreshToken != null) {
        return result.result[0];
      } else {
        return null;
      }
    } on BaseException catch (error) {
      _logger.info(error);
      _logger.info("Could not refresh login session");
      return null;
    } on Exception catch (error) {
      _logger.severe(error);
      return null;
    }
  }

  Future<UserLogin?> _verifyUserLogin(String accessToken, String id) async {
    Map<String, String> query = {"id": id};

    try {
      var result = await get(
          filter: query, additionalRoute: "/verify", bearerToken: accessToken);

      if (result.result[0].accessToken != null) {
        return result.result[0];
      } else {
        return null;
      }
    } on BaseException catch (error) {
      _logger.info(error);
      _logger.info("Could not verify validity of access token");
      return null;
    } on Exception catch (error) {
      _logger.severe(error);
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
      String? expiration = loginCreds.expiresIn?.toIso8601String();
      int id = loginCreds.user.id;

      await SecureStore.writeValue("access_token", accessToken ?? "");
      await SecureStore.writeValue("refresh_token", refreshToken ?? "");
      await SecureStore.writeValue("access_expiration", expiration.toString());
      await SecureStore.writeValue("user_ref_id", id.toString());

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
    await SecureStore.deleteValue("user_ref_id");

    loggedUser = null;
    notifyListeners();
  }
}
