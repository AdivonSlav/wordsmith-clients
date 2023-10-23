import "package:json_annotation/json_annotation.dart";

part "image_insert.g.dart";

@JsonSerializable()
class ImageInsert {
  final String encodedImage;
  final String format;
  final int? size;

  ImageInsert(this.encodedImage, this.format, this.size);

  factory ImageInsert.fromJson(Map<String, dynamic> json) =>
      _$ImageInsertFromJson(json);

  Map<String, dynamic> toJson() => _$ImageInsertToJson(this);
}
