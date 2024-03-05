import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/ebook_report/ebook_report.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class EbookReportsProvider extends BaseProvider<EbookReport> {
  final _logger = LogManager.getLogger("EbookReportsProvider");

  EbookReportsProvider() : super("ebook-reports");

  Future<Result<QueryResult<EbookReport>>> getEBookReports(
      {required int page,
      required int pageSize,
      String? reason,
      DateTime? reportDate}) async {
    var accessToken = await SecureStore.getValue("access_token");
    try {
      Map<String, String> queries = {
        "page": page.toString(),
        "pageSize": pageSize.toString(),
      };

      if (reason != null && reason.isNotEmpty) {
        queries["reason"] = reason;
      }
      if (reportDate != null) {
        queries["reportDate"] = reportDate.toIso8601String();
      }

      var result = await get(
        filter: queries,
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
  EbookReport fromJson(data) {
    return EbookReport.fromJson(data);
  }
}
