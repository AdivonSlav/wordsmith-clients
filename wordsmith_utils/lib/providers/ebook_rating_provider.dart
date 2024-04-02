import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook_rating/ebook_rating.dart';
import 'package:wordsmith_utils/models/ebook_rating/ebook_rating_insert.dart';
import 'package:wordsmith_utils/models/ebook_rating/ebook_rating_update.dart';
import 'package:wordsmith_utils/models/entity_result.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class EbookRatingProvider extends BaseProvider<EbookRating> {
  final _logger = LogManager.getLogger("EbookRatingProvider");

  EbookRatingProvider() : super("ebook-ratings");

  Future<Result<QueryResult<EbookRating>>> getRatings({
    int? rating,
    int? userId,
    int? ebookId,
    int? page,
    int? pageSize,
    String? orderBy,
  }) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var filter = {
        "rating": rating,
        "userId": userId,
        "ebookId": ebookId,
        "page": page,
        "pageSize": page,
        "orderBy": orderBy
      };

      var result = await get(
        filter: filter,
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

  Future<Result<EntityResult<EbookRating>>> addRating(
      EbookRatingInsert insert) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await post(
        request: insert,
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

  Future<Result<EntityResult<EbookRating>>> updateRating({
    required int ratingId,
    required EbookRatingUpdate update,
  }) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await put(
        id: ratingId,
        request: update,
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
  EbookRating fromJson(data) {
    return EbookRating.fromJson(data);
  }
}
