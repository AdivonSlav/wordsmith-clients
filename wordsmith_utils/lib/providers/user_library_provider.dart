import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/user_library.dart';
import 'package:wordsmith_utils/models/user_library_insert.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class UserLibraryProvider extends BaseProvider<UserLibrary> {
  UserLibraryProvider() : super("user-libraries");

  Future<UserLibrary> addToUserLibrary(int eBookId) async {
    var accessToken = await SecureStore.getValue("access_token");
    var insert = UserLibraryInsert(eBookId);

    return post(
        request: insert, bearerToken: accessToken ?? "", retryForRefresh: true);
  }

  Future<QueryResult<UserLibrary>> getLibraryEntry(
      {required int eBookId}) async {
    var accessToken = await SecureStore.getValue("access_token");

    return get(
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
        additionalRoute: "/$eBookId");
  }

  Future<QueryResult<UserLibrary>> getLibraryEntries(
      {int? maturityRatingId,
      bool? isRead,
      required int page,
      required int pageSize}) async {
    var accessToken = await SecureStore.getValue("access_token");

    Map<String, String> query = {
      "page": page.toString(),
      "pageSize": pageSize.toString(),
    };

    if (maturityRatingId != null) {
      query["maturityRatingId"] = maturityRatingId.toString();
    }
    if (isRead != null) query["isRead"] = isRead.toString();

    return get(
      filter: query,
      bearerToken: accessToken ?? "",
      retryForRefresh: true,
    );
  }

  @override
  UserLibrary fromJson(data) {
    return UserLibrary.fromJson(data);
  }
}
