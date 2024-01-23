import 'package:wordsmith_utils/models/maturity_rating.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';

class MaturityRatingsProvider extends BaseProvider<MaturityRating> {
  MaturityRatingsProvider() : super("maturity-ratings");

  Future<QueryResult<MaturityRating>> getMaturityRatings(
      {required int page, required int pageSize, String? name}) async {
    Map<String, String> queries = {
      "page": page.toString(),
      "pageSize": pageSize.toString(),
    };

    if (name != null) {
      queries["name"] = name;
    }

    var result = await get(filter: queries);

    return result;
  }

  @override
  MaturityRating fromJson(data) {
    return MaturityRating.fromJson(data);
  }
}
