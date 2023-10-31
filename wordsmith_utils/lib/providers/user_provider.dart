import "package:wordsmith_utils/models/user.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("users");

  Future<User?> getLoggedUser() async {
    String? accessToken = await SecureStore.getValue("access_token");
    String? expiration = await SecureStore.getValue("access_expiration");

    if (accessToken == null || accessToken.isEmpty) return null;

    var result =
        await get(additionalRoute: "/profile", bearerToken: accessToken);

    return result.result[0];
  }

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }
}
