import 'package:wordsmith_utils/models/genre.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("genres");

  Future<QueryResult<Genre>> getGenres(
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
  Genre fromJson(data) {
    return Genre.fromJson(data);
  }
}
