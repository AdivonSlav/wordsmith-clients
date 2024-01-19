import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "package:file_selector/file_selector.dart";
import "package:flutter/widgets.dart";
import "package:mime/mime.dart";
import "package:wordsmith_utils/models/image_insert.dart";

abstract class ImageHelper {
  // Allowed file formats are done on a per-platform basis
  // All platforms support extensions, but iOS requires UTIs
  static final XTypeGroup _allowedTypes = XTypeGroup(
    label: "Images (jpg, png)",
    extensions: !Platform.isIOS ? <String>["jpg", "jpeg", "png"] : null,
    uniformTypeIdentifiers:
        Platform.isIOS ? <String>["public.jpeg", "public.png"] : null,
  );
  // Max allowed image size in bytes
  static const int _maxSize = 5242880;

  static Future<XFile?> pickImage() async {
    return await openFile(acceptedTypeGroups: <XTypeGroup>[_allowedTypes]);
  }

  static Future<bool> verifySize(XFile file) async {
    var fileLength = await file.length();

    return fileLength <= _maxSize;
  }

  static Future<ImageInsert?> toImageInsert(XFile file) async {
    final Uint8List bytes = await file.readAsBytes();
    final String asBase64 = base64Encode(bytes);
    String? mimeType = lookupMimeType(file.path, headerBytes: [0xFF, 0xD8]);
    String format = mimeType?.split("/")[1] ?? "";
    List<String>? allowedExtensions = _allowedTypes.extensions;

    if (allowedExtensions != null && format.isNotEmpty) {
      if (!allowedExtensions.contains(format)) return null;
    }

    return ImageInsert(asBase64, format, bytes.length);
  }
}
