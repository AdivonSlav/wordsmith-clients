import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/user/user_login.dart";
import "package:wordsmith_utils/models/user/user_login_request.dart";
import "package:wordsmith_utils/providers/base_provider.dart";

class UserLoginProvider extends BaseProvider<UserLogin> {
  final _logger = LogManager.getLogger("UserLoginProvider");

  UserLoginProvider() : super("users/login");

  Future<Result<UserLogin>> getUserLogin(UserLoginRequest loginRequest) async {
    try {
      var result = await post(request: loginRequest);

      if (result.result?.accessToken != null &&
          result.result?.refreshToken != null) {
        return Success(result.result!);
      } else {
        return Failure(BaseException("Could not login"));
      }
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  @override
  UserLogin fromJson(dynamic data) {
    return UserLogin.fromJson(data);
  }
}
