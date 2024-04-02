import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook_rating/ebook_rating_statistics.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';

class EbookRatingStatisticsProvider
    extends BaseProvider<EbookRatingStatistics> {
  final _logger = LogManager.getLogger("EbookRatingStatisticsProvider");

  EbookRatingStatisticsProvider() : super("ebook-ratings/statistics");

  Future<Result<QueryResult<EbookRatingStatistics>>> getStatistics(
      int ebookId) async {
    try {
      var result = await get(additionalRoute: "/$ebookId");

      return Success(result);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  @override
  EbookRatingStatistics fromJson(data) {
    return EbookRatingStatistics.fromJson(data);
  }
}
