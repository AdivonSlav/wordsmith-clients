import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category_add.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category_remove.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class UserLibraryCategoryProvider extends BaseProvider<UserLibraryCategory> {
  final _logger = LogManager.getLogger("UserLibraryCategoryProvider");

  UserLibraryCategoryProvider() : super("user-library-categories");

  Future<Result<QueryResult<UserLibraryCategory>>>
      getLibraryCategories() async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result =
          await get(bearerToken: accessToken ?? "", retryForRefresh: true);

      return Success(result);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<String>> addEntriesToCategory(
      UserLibraryCategoryAdd add) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await post(
        request: add,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.message ?? "Success");
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<String>> removeCategoryFromEntries(
      UserLibraryCategoryRemove remove) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await put(
        request: remove,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.message ?? "Success");
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<String>> deleteCategory(int categoryId) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await delete(
        id: categoryId,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.message ?? "Success");
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  @override
  UserLibraryCategory fromJson(data) {
    return UserLibraryCategory.fromJson(data);
  }
}
