import 'package:json_annotation/json_annotation.dart';

part "ebook_parse.g.dart";

@JsonSerializable()
class EBookParse {
  final String title;
  final String authorName;
  final String description;
  final String encodedCoverArt;
  final List<String> chapters;

  EBookParse(this.title, this.authorName, this.description,
      this.encodedCoverArt, this.chapters);

  factory EBookParse.fromJson(Map<String, dynamic> json) =>
      _$EBookParseFromJson(json);

  Map<String, dynamic> toJson() => _$EBookParseToJson(this);
}
