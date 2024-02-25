import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/maturity_rating/maturity_rating.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';

class MaturityRatingsProvider extends BaseProvider<MaturityRating> {
  final _logger = LogManager.getLogger("MaturityRatingsProvider");

  MaturityRatingsProvider() : super("maturity-ratings");

  Future<Result<QueryResult<MaturityRating>>> getMaturityRatings(
      {int? page, int? pageSize, String? name}) async {
    try {
      Map<String, String> queries = {};

      if (page != null) {
        queries["page"] = page.toString();
      }

      if (pageSize != null) {
        queries["pageSize"] = pageSize.toString();
      }

      if (name != null) {
        queries["name"] = name;
      }

      var result = queries.isEmpty ? await get() : await get(filter: queries);

      return Success(result);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  @override
  MaturityRating fromJson(data) {
    return MaturityRating.fromJson(data);
  }
}
