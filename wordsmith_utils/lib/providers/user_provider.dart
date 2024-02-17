import "package:wordsmith_utils/models/entity_result.dart";
import "package:wordsmith_utils/models/user/user.dart";
import "package:wordsmith_utils/models/user/user_insert.dart";
import "package:wordsmith_utils/models/user/user_update.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("users");

  Future<EntityResult<User>> postNewUser(UserInsert userInsert) async {
    var result = await post(additionalRoute: "/register", request: userInsert);

    return result;
  }

  Future<User> getLoggedUser() async {
    String? accessToken = await SecureStore.getValue("access_token");

    var result = await get(
      additionalRoute: "/profile",
      bearerToken: accessToken ?? "",
      retryForRefresh: true,
    );

    return result.result[0];
  }

  Future<EntityResult<User>> updateLoggeduser(UserUpdate update) async {
    String? accessToken = await SecureStore.getValue("access_token");

    var result = await put(
      request: update,
      additionalRoute: "/profile",
      bearerToken: accessToken ?? "",
      retryForRefresh: true,
    );

    return result;
  }

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }
}
