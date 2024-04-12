import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/exceptions/exception_types.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/entity_result.dart";
import "package:wordsmith_utils/models/image/image_insert.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/user/user.dart";
import "package:wordsmith_utils/models/user/user_change_access.dart";
import "package:wordsmith_utils/models/user/user_insert.dart";
import "package:wordsmith_utils/models/user/user_search.dart";
import "package:wordsmith_utils/models/user/user_update.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class UserProvider extends BaseProvider<User> {
  final _logger = LogManager.getLogger("UserProvider");

  UserProvider() : super("users");

  Future<Result<User>> getUser(int id) async {
    String? accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await get(
        additionalRoute: "/$id",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.result[0]);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      return Failure(BaseException("Internal app error",
          type: ExceptionType.internalAppError));
    }
  }

  Future<Result<QueryResult<User>>> getUsers(UserSearch search,
      {int? page, int? pageSize, String? orderBy}) async {
    String? accessToken = await SecureStore.getValue("access_token");

    try {
      var query = search.toJson();
      query["page"] = page;
      query["pageSize"] = pageSize;
      query["orderBy"] = orderBy;

      var result = await get(
        filter: query,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      return Failure(BaseException("Internal app error",
          type: ExceptionType.internalAppError));
    }
  }

  Future<Result<User>> postNewUser(UserInsert userInsert) async {
    try {
      var result =
          await post(additionalRoute: "/register", request: userInsert);

      return Success(result.result!);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      return Failure(BaseException("Internal app error",
          type: ExceptionType.internalAppError));
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
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      return Failure(BaseException("Internal app error",
          type: ExceptionType.internalAppError));
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
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      return Failure(BaseException("Internal app error",
          type: ExceptionType.internalAppError));
    }
  }

  Future<Result<User>> updateProfileImage(ImageInsert request) async {
    String? accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await put(
        request: request,
        additionalRoute: "/profile/image",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.result!);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      return Failure(BaseException("Internal app error",
          type: ExceptionType.internalAppError));
    }
  }

  Future<Result<EntityResult<User>>> changeUserAccess({
    required int userId,
    required UserChangeAccess request,
    bool notify = false,
  }) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await put(
        request: request,
        additionalRoute: "/$userId/change-access",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      if (notify) notifyListeners();

      return Success(result);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      return Failure(BaseException("Internal app error",
          type: ExceptionType.internalAppError));
    }
  }

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }
}
