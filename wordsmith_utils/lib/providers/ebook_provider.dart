import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/ebook/ebook_insert.dart';
import 'package:wordsmith_utils/models/ebook/ebook_search.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class EbookProvider extends BaseProvider<Ebook> {
  final _logger = LogManager.getLogger("EBookProvider");

  EbookProvider() : super("ebooks");

  Future<Result<QueryResult<Ebook>>> getEbooks(EbookSearch search,
      {int? page, int? pageSize, String? orderBy}) async {
    var accessToken = await SecureStore.getValue("access_token");

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

  Future<Result<QueryResult<Ebook>>> getEbook(int ebookId) async {
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
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      return Failure(BaseException("Internal app error",
          type: ExceptionType.internalAppError));
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
      _logger.severe(error);
      return Failure(error);
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      return Failure(BaseException("Internal app error",
          type: ExceptionType.internalAppError));
    }
  }

  Future<Result<Ebook>> hideEbook(
      {required int ebookId, bool notify = false}) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await put(
        additionalRoute: "/$ebookId/hide",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      if (notify) notifyListeners();

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

  Future<Result<Ebook>> unhideEbook(
      {required int ebookId, bool notify = false}) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await put(
        additionalRoute: "/$ebookId/unhide",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      if (notify) notifyListeners();

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

  @override
  Ebook fromJson(data) {
    return Ebook.fromJson(data);
  }
}
