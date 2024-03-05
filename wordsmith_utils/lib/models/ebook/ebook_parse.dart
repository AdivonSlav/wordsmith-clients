import 'package:json_annotation/json_annotation.dart';

part "ebook_parse.g.dart";

@JsonSerializable()
class EbookParse {
  final String title;
  final String description;
  final String encodedCoverArt;
  final List<String> chapters;

  EbookParse(this.title, this.description, this.encodedCoverArt, this.chapters);

  factory EbookParse.fromJson(Map<String, dynamic> json) =>
      _$EbookParseFromJson(json);

  Map<String, dynamic> toJson() => _$EbookParseToJson(this);
}
