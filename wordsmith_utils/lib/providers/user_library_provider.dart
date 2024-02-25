import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
import 'package:wordsmith_utils/models/user_library/user_library_insert.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class UserLibraryProvider extends BaseProvider<UserLibrary> {
  final _logger = LogManager.getLogger("UserLibraryProvider");

  Result<UserLibrary>? _libraryEntry;
  Result<UserLibrary>? get libraryEntry => _libraryEntry;

  Result<QueryResult<UserLibrary>>? _libraryEntries;
  Result<QueryResult<UserLibrary>>? get libraryEntries => _libraryEntries;

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
    } on Exception catch (error) {
      _logger.severe(error);
      return Failure(error.toString());
    }
  }

  Future<void> getLibraryEntryByEBook({required int eBookId}) async {
    isLoading = true;
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

      _libraryEntry = Success(result.result[0]);
      isLoading = false;
    } on Exception catch (error) {
      _logger.severe(error);
      _libraryEntry = Failure(error.toString());
      isLoading = false;
    }
  }

  Future<void> getLibraryEntries(
      {int? maturityRatingId,
      bool? isRead,
      String? orderBy,
      int? eBookId,
      int? libraryCategoryId,
      required int page,
      required int pageSize}) async {
    isLoading = true;
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

      _libraryEntries = Success(result);
      isLoading = false;
    } on Exception catch (error) {
      _logger.severe(error);
      _libraryEntries = Failure(error.toString());
      isLoading = false;
    }
  }

  @override
  UserLibrary fromJson(data) {
    return UserLibrary.fromJson(data);
  }
}
