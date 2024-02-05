import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/user_library.dart';
import 'package:wordsmith_utils/models/user_library_insert.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class UserLibraryProvider extends BaseProvider<UserLibrary> {
  UserLibraryProvider() : super("user-libraries");

  Future<UserLibrary> addToUserLibrary(UserLibraryInsert insert) async {
    var accessToken = await SecureStore.getValue("access_token");

    return await post(
        request: insert, bearerToken: accessToken ?? "", retryForRefresh: true);
  }

  Future<QueryResult<UserLibrary>> getUserLibrary(
      {required int page, required int pageSize}) async {
    var accessToken = await SecureStore.getValue("access_token");

    Map<String, String> queries = {
      "page": page.toString(),
      "pageSize": pageSize.toString(),
    };

    return await get(
        filter: queries, bearerToken: accessToken ?? "", retryForRefresh: true);
  }
}
