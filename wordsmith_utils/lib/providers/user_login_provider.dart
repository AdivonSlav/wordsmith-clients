import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/user/user_login.dart";
import "package:wordsmith_utils/providers/base_provider.dart";

class UserLoginProvider extends BaseProvider<UserLogin> {
  final _logger = LogManager.getLogger("UserLoginProvider");

  UserLoginProvider() : super("users/login");

  Future<Result<UserLogin>> getUserLogin(
      String username, String password) async {
    try {
      Map<String, String> request = {
        "username": username,
        "password": password,
      };

      var result = await post(request: request);

      if (result.result?.accessToken != null &&
          result.result?.refreshToken != null) {
        return Success(result.result!);
      } else {
        return const Failure("Could not login");
      }
    } on Exception catch (error) {
      _logger.severe(error);
      return Failure(error.toString());
    }
  }

  @override
  UserLogin fromJson(dynamic data) {
    return UserLogin.fromJson(data);
  }
}
