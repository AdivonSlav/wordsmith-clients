import 'package:json_annotation/json_annotation.dart';

part "ebook_insert.g.dart";

@JsonSerializable()
class EbookInsert {
  final String title;
  final String description;
  final String encodedCoverArt;
  final List<String> chapters;
  final double? price;
  final int authorId;
  final List<int> genreIds;
  final int maturityRatingId;

  EbookInsert(this.title, this.description, this.encodedCoverArt, this.chapters,
      this.price, this.authorId, this.genreIds, this.maturityRatingId);

  factory EbookInsert.fromJson(Map<String, dynamic> json) =>
      _$EbookInsertFromJson(json);

  Map<String, dynamic> toJson() => _$EbookInsertToJson(this);
}
