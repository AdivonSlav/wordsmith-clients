import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/translate/translation_request.dart';
import 'package:wordsmith_utils/models/translate/translation_response.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class TranslationProvider extends BaseProvider<TranslationResponse> {
  final _logger = LogManager.getLogger("TranslationProvider");

  TranslationProvider() : super("translate");

  Future<Result<TranslationResponse>> getTranslation(
      TranslationRequest request) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var map = request.toJson();

      var result = await get(
        filter: map,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.result.first);
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
  TranslationResponse fromJson(data) {
    return TranslationResponse.fromJson(data);
  }
}
