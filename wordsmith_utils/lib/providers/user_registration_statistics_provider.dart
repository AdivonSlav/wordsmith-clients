import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/statistics/statistics_request.dart';
import 'package:wordsmith_utils/models/user/user_registration_statistics.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class UserRegistrationStatisticsProvider
    extends BaseProvider<UserRegistrationStatistics> {
  final _logger = LogManager.getLogger("UserRegistrationStatisticsProvider");

  UserRegistrationStatisticsProvider()
      : super("users/statistics/registrations");

  Future<Result<QueryResult<UserRegistrationStatistics>>>
      getRegistrationStatistics(
    StatisticsRequest request, {
    int? pageSize,
  }) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var map = request.toJson();
      map["pageSize"] = pageSize;

      var result = await get(
        filter: map,
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
  UserRegistrationStatistics fromJson(data) {
    return UserRegistrationStatistics.fromJson(data);
  }
}
