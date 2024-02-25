import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/genre/genre.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  final _logger = LogManager.getLogger("GenreProvider");

  GenreProvider() : super("genres");

  Future<Result<QueryResult<Genre>>> getGenres(
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
  Genre fromJson(data) {
    return Genre.fromJson(data);
  }
}
