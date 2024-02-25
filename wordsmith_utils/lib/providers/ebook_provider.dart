import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/ebook/ebook_insert.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class EBookProvider extends BaseProvider<EBook> {
  final _logger = LogManager.getLogger("EBookProvider");

  EBookProvider() : super("ebooks");

  Future<Result<QueryResult<EBook>>> getNewlyAdded(
      {required int page, required int pageSize}) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      Map<String, String> query = {
        "page": page.toString(),
        "pageSize": pageSize.toString(),
        "orderBy": "UpdatedDate:desc"
      };

      var result = await get(
          filter: query, bearerToken: accessToken ?? "", retryForRefresh: true);

      return Success(result);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<EBook>> postEBook(EBookInsert insert, TransferFile file) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      Map<String, dynamic> fields = {
        "title": insert.title,
        "description": insert.description,
        "encodedCoverArt": insert.encodedCoverArt,
        "chapters": insert.chapters,
        "authorId": insert.authorId.toString(),
        "genreIds": insert.genreIds,
        "maturityRatingId": insert.maturityRatingId.toString(),
      };

      Map<String, TransferFile> files = {"file": file};

      var result = await postMultipart(
        files: files,
        fields: fields,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.result!);
    } on BaseException catch (error) {
      return Failure(error);
    }
  }

  @override
  EBook fromJson(data) {
    return EBook.fromJson(data);
  }
}
