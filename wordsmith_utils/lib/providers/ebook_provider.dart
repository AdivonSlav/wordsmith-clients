import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/ebook/ebook_insert.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class EbookProvider extends BaseProvider<Ebook> {
  final _logger = LogManager.getLogger("EBookProvider");

  EbookProvider() : super("ebooks");

  Future<Result<QueryResult<Ebook>>> getNewlyAdded(
      {required int page, required int pageSize}) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      Map<String, String> query = {
        "page": page.toString(),
        "pageSize": pageSize.toString(),
        "orderBy": "UpdatedDate:desc"
      };

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

  Future<Result<QueryResult<Ebook>>> getById(int ebookId) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await get(
        additionalRoute: "/$ebookId",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<Ebook>> postEBook(EbookInsert insert, TransferFile file) async {
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

      if (insert.price != null) {
        fields["price"] = insert.price!;
      }

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
  Ebook fromJson(data) {
    return Ebook.fromJson(data);
  }
}
