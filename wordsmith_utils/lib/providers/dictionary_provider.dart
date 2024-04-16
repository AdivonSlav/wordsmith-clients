import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/dictionary/dictionary_response.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class DictionaryProvider extends BaseProvider<DictionaryResponse> {
  final _logger = LogManager.getLogger("EbookChapterProvider");

  DictionaryProvider() : super("dictionary");

  Future<Result<DictionaryResponse>> getDictionaryEntries(
      String searchTerm) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var map = {
        "searchTerm": searchTerm,
      };

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
  DictionaryResponse fromJson(data) {
    return DictionaryResponse.fromJson(data);
  }
}
