import "package:wordsmith_utils/models/ebook/ebook_parse.dart";
import "package:wordsmith_utils/models/entity_result.dart";
import "package:wordsmith_utils/models/transfer_file.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class EBookParseProvider extends BaseProvider<EBookParse> {
  EBookParseProvider() : super("ebooks");

  Future<EntityResult<EBookParse>> getParsed(TransferFile file) async {
    var accessToken = await SecureStore.getValue("access_token");

    Map<String, TransferFile> files = {"file": file};

    return await postMultipart(
      files: files,
      additionalRoute: "/parse",
      bearerToken: accessToken ?? "",
      retryForRefresh: true,
    );
  }

  @override
  EBookParse fromJson(data) {
    return EBookParse.fromJson(data);
  }
}
