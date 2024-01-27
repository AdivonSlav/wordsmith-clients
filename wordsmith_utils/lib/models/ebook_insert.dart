import 'package:json_annotation/json_annotation.dart';

part "ebook_insert.g.dart";

@JsonSerializable()
class EBookInsert {
  final String title;
  final String description;
  final String encodedCoverArt;
  final List<String> chapters;
  final double? price;
  final int authorId;
  final List<int> genreIds;
  final int maturityRatingId;

  EBookInsert(this.title, this.description, this.encodedCoverArt, this.chapters,
      this.price, this.authorId, this.genreIds, this.maturityRatingId);

  factory EBookInsert.fromJson(Map<String, dynamic> json) =>
      _$EBookInsertFromJson(json);

  Map<String, dynamic> toJson() => _$EBookInsertToJson(this);
}
