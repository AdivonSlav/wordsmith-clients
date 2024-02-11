import "package:wordsmith_utils/models/ebook_report/ebook_report.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class EBookReportsProvider extends BaseProvider<EBookReport> {
  EBookReportsProvider() : super("ebook-reports");

  Future<QueryResult<EBookReport>> getEBookReports(
      {required int page,
      required int pageSize,
      String? reason,
      DateTime? reportDate}) async {
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

    var accessToken = await SecureStore.getValue("access_token");

    var result = await get(
      filter: queries,
      bearerToken: accessToken ?? "",
      retryForRefresh: true,
    );

    return result;
  }

  @override
  EBookReport fromJson(data) {
    return EBookReport.fromJson(data);
  }
}
