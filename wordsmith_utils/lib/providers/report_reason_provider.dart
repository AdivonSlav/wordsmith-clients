import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/report/report_reason.dart';
import 'package:wordsmith_utils/models/report/report_reason_search.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class ReportReasonProvider extends BaseProvider<ReportReason> {
  final _logger = LogManager.getLogger("ReportReasonProvider");

  ReportReasonProvider() : super("reports/reasons");

  Future<Result<QueryResult<ReportReason>>> getReportReasons(
    ReportReasonSearch search, {
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

  @override
  ReportReason fromJson(data) {
    return ReportReason.fromJson(data);
  }
}
