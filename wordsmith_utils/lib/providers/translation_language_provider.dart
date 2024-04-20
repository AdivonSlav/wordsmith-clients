import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/translate/language.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class TranslationLanguageProvider extends BaseProvider<Language> {
  final _logger = LogManager.getLogger("TranslationLanguageProvider");

  TranslationLanguageProvider() : super("translate/languages");

  Future<Result<QueryResult<Language>>> getSupportedLanguages() async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var result = await get(
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
  Language fromJson(data) {
    return Language.fromJson(data);
  }
}
