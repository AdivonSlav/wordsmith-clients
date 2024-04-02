import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook_chapter/ebook_chapter.dart';
import 'package:wordsmith_utils/models/ebook_chapter/ebook_chapter_search.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';

class EbookChapterProvider extends BaseProvider<EbookChapter> {
  final _logger = LogManager.getLogger("EbookChapterProvider");

  EbookChapterProvider() : super("ebook-chapters");

  Future<Result<QueryResult<EbookChapter>>> getChapters(
    EbookChapterSearch search, {
    int? page,
    int? pageSize,
    String? orderBy,
  }) async {
    try {
      var map = search.toJson();
      map["page"] = page;
      map["pageSize"] = pageSize;
      map["orderBy"] = orderBy;

      var result = await get(
        filter: map,
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
  EbookChapter fromJson(data) {
    return EbookChapter.fromJson(data);
  }
}
