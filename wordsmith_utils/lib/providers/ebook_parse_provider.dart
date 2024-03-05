import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/ebook/ebook_parse.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/transfer_file.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class EbookParseProvider extends BaseProvider<EbookParse> {
  final _logger = LogManager.getLogger("EBookParseProvider");

  EbookParseProvider() : super("ebooks");

  Future<Result<EbookParse>> getParsed(TransferFile file) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      Map<String, TransferFile> files = {"file": file};

      var result = await postMultipart(
        files: files,
        additionalRoute: "/parse",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(result.result!);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  @override
  EbookParse fromJson(data) {
    return EbookParse.fromJson(data);
  }
}
