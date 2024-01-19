import "package:wordsmith_utils/models/ebook_parse.dart";
import "package:wordsmith_utils/models/transfer_file.dart";
import "package:wordsmith_utils/providers/base_provider.dart";

class EBookParseProvider extends BaseProvider<EBookParse> {
  EBookParseProvider() : super("ebooks");

  Future<EBookParse> getParsed(TransferFile file) async {
    Map<String, TransferFile> files = {"file": file};

    return await postMultipart(files: files, additionalRoute: "/parse");
  }

  @override
  EBookParse fromJson(data) {
    return EBookParse.fromJson(data);
  }
}
