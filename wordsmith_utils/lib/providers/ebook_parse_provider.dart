import "package:wordsmith_utils/models/ebook_parse.dart";
import "package:wordsmith_utils/models/transfer_file.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

class EBookParseProvider extends BaseProvider<EBookParse> {
  EBookParseProvider() : super("ebooks");

  Future<EBookParse> getParsed(TransferFile file) async {
    var accessToken = await SecureStore.getValue("access_token");

    Map<String, TransferFile> files = {"file": file};

    return await postMultipart(
      files: files,
      additionalRoute: "/parse",
      bearerToken: accessToken ?? "",
    );
  }

  @override
  EBookParse fromJson(data) {
    return EBookParse.fromJson(data);
  }
}
