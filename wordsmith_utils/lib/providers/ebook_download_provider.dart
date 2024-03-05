import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class EbookDownloadProvider extends BaseProvider<void> {
  final _logger = LogManager.getLogger("EbookDownloadProvider");

  EbookDownloadProvider() : super("ebooks");

  Future<Result<TransferFile>> download(int ebookId) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var file = await getBytes(
          additionalRoute: "/$ebookId/download",
          bearerToken: accessToken ?? "");

      return Success(file);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }
}
