import "dart:io";
import "package:file_selector/file_selector.dart";
import "package:wordsmith_utils/models/transfer_file.dart";

abstract class EpubHelper {
  // Allowed file formats are done on a per-platform basis
  // All platforms support extensions, but iOS requires UTIs
  static final XTypeGroup _allowedTypes = XTypeGroup(
    label: "EPUB (epub)",
    extensions: !Platform.isIOS ? <String>["epub"] : null,
    uniformTypeIdentifiers:
        Platform.isIOS ? <String>["org.idpf.epub-container"] : null,
  );
  // Max allowed image size in bytes
  static const int _maxSize = 10485760;

  static Future<XFile?> pickEpub() async {
    return await openFile(acceptedTypeGroups: <XTypeGroup>[_allowedTypes]);
  }

  static Future<TransferFile?> verify(XFile file) async {
    var fileLength = await file.length();

    if (fileLength > _maxSize || fileLength <= 0) {
      return null;
    }

    if (file.mimeType != "application/epub+zip") {
      return null;
    }

    return TransferFile(file, "${file.name}.epub");
  }
}
