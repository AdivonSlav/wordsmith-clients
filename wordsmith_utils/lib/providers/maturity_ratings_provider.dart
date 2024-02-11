import 'package:wordsmith_utils/models/maturity_rating/maturity_rating.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';

class MaturityRatingsProvider extends BaseProvider<MaturityRating> {
  MaturityRatingsProvider() : super("maturity-ratings");

  Future<QueryResult<MaturityRating>> getMaturityRatings(
      {int? page, int? pageSize, String? name}) async {
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

    return queries.isEmpty ? await get() : await get(filter: queries);
  }

  @override
  MaturityRating fromJson(data) {
    return MaturityRating.fromJson(data);
  }
}
