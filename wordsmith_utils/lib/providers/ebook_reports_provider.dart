import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/exceptions/exception_types.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/ebook_report/ebook_report.dart";
import "package:wordsmith_utils/models/ebook_report/ebook_report_email_send.dart";
import "package:wordsmith_utils/models/ebook_report/ebook_report_insert.dart";
import "package:wordsmith_utils/models/ebook_report/ebook_report_search.dart";
import "package:wordsmith_utils/models/ebook_report/ebook_report_update.dart";
import "package:wordsmith_utils/models/entity_result.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class EbookReportsProvider extends BaseProvider<EbookReport> {
  final _logger = LogManager.getLogger("EbookReportsProvider");

  EbookReportsProvider() : super("ebook-reports");

  Future<Result<QueryResult<EbookReport>>> getEbookReports(
    EbookReportSearch search, {
    int? page,
    int? pageSize,
    String? orderBy,
  }) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var map = search.toJson();
      map["page"] = page;
      map["pageSize"] = pageSize;
      map["orderBy"] = orderBy;

      var result = await get(
        filter: map,
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

  Future<Result<QueryResult<EbookReport>>> getEbookReport(int id) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await get(
        additionalRoute: "/$id",
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

  Future<Result<EntityResult<EbookReport>>> sendEmail(
      EbookReportEmailSend request) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await post(
        request: request,
        additionalRoute: "/email",
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

  Future<Result<EntityResult<EbookReport>>> postReport(
      EbookReportInsert request) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await post(
        request: request,
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

  Future<Result<EntityResult<EbookReport>>> updateReport(
      {required int id,
      required EbookReportUpdate request,
      bool notify = false}) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await put(
        id: id,
        request: request,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      if (notify) notifyListeners();

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

  @override
  EbookReport fromJson(data) {
    return EbookReport.fromJson(data);
  }
}
