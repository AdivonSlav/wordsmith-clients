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

  Result<QueryResult<UserLibraryCategory>>? _libraryCategories;
  Result<QueryResult<UserLibraryCategory>>? get libraryCategories =>
      _libraryCategories;

  UserLibraryCategoryProvider() : super("user-library-categories");

  Future<void> getLibraryCategories() async {
    isLoading = true;
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result =
          await get(bearerToken: accessToken ?? "", retryForRefresh: true);

      _libraryCategories = Success(result);
      isLoading = false;
    } on Exception catch (error) {
      _libraryCategories = Failure(error.toString());
      isLoading = false;
      _logger.severe(error);
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
    } on Exception catch (error) {
      _logger.severe(error);
      return Failure(error.toString());
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
    } on Exception catch (error) {
      _logger.severe(error);
      return Failure(error.toString());
    }
  }

  @override
  UserLibraryCategory fromJson(data) {
    return UserLibraryCategory.fromJson(data);
  }
}
