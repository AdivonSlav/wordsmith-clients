import 'package:wordsmith_utils/models/genre/genre.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("genres");

  Future<QueryResult<Genre>> getGenres(
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
  Genre fromJson(data) {
    return Genre.fromJson(data);
  }
}
