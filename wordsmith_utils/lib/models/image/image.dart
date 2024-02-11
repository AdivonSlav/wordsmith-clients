import "package:json_annotation/json_annotation.dart";

part "image.g.dart";

@JsonSerializable()
class Image {
  final String? imagePath;
  final String? encodedImage;
  final String format;
  final int size;

  Image(this.imagePath, this.encodedImage, this.format, this.size);

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

  Map<String, dynamic> toJson() => _$ImageToJson(this);
}
