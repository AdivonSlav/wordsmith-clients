import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/user/user.dart";
import "package:wordsmith_utils/models/user/user_insert.dart";
import "package:wordsmith_utils/models/user/user_update.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class UserProvider extends BaseProvider<User> {
  final _logger = LogManager.getLogger("UserProvider");

  UserProvider() : super("users");

  Future<Result<User>> postNewUser(UserInsert userInsert) async {
    try {
      var result =
          await post(additionalRoute: "/register", request: userInsert);

      return Success(result.result!);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<User>> getLoggedUser() async {
    String? accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await get(
        additionalRoute: "/profile",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.result[0]);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<User>> updateLoggeduser(UserUpdate update) async {
    String? accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await put(
        request: update,
        additionalRoute: "/profile",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.result!);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }
}
