import "package:wordsmith_utils/models/entity_result.dart";
import "package:wordsmith_utils/models/user/user_login.dart";
import "package:wordsmith_utils/providers/base_provider.dart";

class UserLoginProvider extends BaseProvider<UserLogin> {
  UserLoginProvider() : super("users/login");

  @override
  UserLogin fromJson(dynamic data) {
    return UserLogin.fromJson(data);
  }

  Future<EntityResult<UserLogin?>> getUserLogin(
      String username, String password) async {
    Map<String, String> request = {
      "username": username,
      "password": password,
    };

    var result = await post(request: request);

    if (result.result?.accessToken != null &&
        result.result?.refreshToken != null) {
      return result;
    } else {
      return EntityResult();
    }
  }
}
