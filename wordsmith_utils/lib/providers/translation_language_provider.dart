import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/translate/supported_languages.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class TranslationLanguageProvider extends BaseProvider<SupportedLanguages> {
  final _logger = LogManager.getLogger("TranslationLanguageProvider");

  TranslationLanguageProvider() : super("translate/languages");

  Future<Result<SupportedLanguages>> getSupportedLanguages() async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await get(
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
  SupportedLanguages fromJson(data) {
    return SupportedLanguages.fromJson(data);
  }
}
