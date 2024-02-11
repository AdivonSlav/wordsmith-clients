import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class UserLibraryCategoryProvider extends BaseProvider<UserLibraryCategory> {
  UserLibraryCategoryProvider() : super("user-library-categories");

  Future<QueryResult<UserLibraryCategory>> getLibraryCategories() async {
    var accessToken = await SecureStore.getValue("access_token");

    return await get(bearerToken: accessToken ?? "", retryForRefresh: true);
  }

  @override
  UserLibraryCategory fromJson(data) {
    return UserLibraryCategory.fromJson(data);
  }
}
