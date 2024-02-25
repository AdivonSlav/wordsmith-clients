import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/ebook/ebook_parse.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/transfer_file.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class EBookParseProvider extends BaseProvider<EBookParse> {
  final _logger = LogManager.getLogger("EBookParseProvider");

  EBookParseProvider() : super("ebooks");

  Future<Result<EBookParse>> getParsed(TransferFile file) async {
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
  EBookParse fromJson(data) {
    return EBookParse.fromJson(data);
  }
}
