import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
import 'package:wordsmith_utils/models/user_library/user_library_insert.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class UserLibraryProvider extends BaseProvider<UserLibrary> {
  final _logger = LogManager.getLogger("UserLibraryProvider");

  UserLibraryProvider() : super("user-libraries");

  Future<Result<UserLibrary>> addToUserLibrary(int eBookId) async {
    var accessToken = await SecureStore.getValue("access_token");
    var insert = UserLibraryInsert(eBookId);

    try {
      var result = await post(
        request: insert,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.result!);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<UserLibrary?>> getLibraryEntryByEbook(
      {required int eBookId}) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      Map<String, String> query = {
        "page": "1",
        "pageSize": "1",
        "eBookId": eBookId.toString()
      };

      var result = await get(
        filter: query,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      if (result.result.isEmpty) {
        return const Success(null);
      }

      return Success(result.result[0]);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<QueryResult<UserLibrary>>> getLibraryEntries(
      {int? maturityRatingId,
      bool? isRead,
      String? orderBy,
      int? eBookId,
      int? libraryCategoryId,
      required int page,
      required int pageSize}) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      Map<String, String> query = {
        "page": page.toString(),
        "pageSize": pageSize.toString(),
      };

      if (maturityRatingId != null) {
        query["maturityRatingId"] = maturityRatingId.toString();
      }
      if (isRead != null) query["isRead"] = isRead.toString();
      if (orderBy != null) query["orderBy"] = orderBy;
      if (eBookId != null) query["eBookId"] = eBookId.toString();
      if (libraryCategoryId != null) {
        query["userLibraryCategoryId"] = libraryCategoryId.toString();
      }

      var result = await get(
        filter: query,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  @override
  UserLibrary fromJson(data) {
    return UserLibrary.fromJson(data);
  }
}
