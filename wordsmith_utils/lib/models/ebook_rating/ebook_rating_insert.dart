import 'package:json_annotation/json_annotation.dart';

part "ebook_rating_insert.g.dart";

@JsonSerializable()
class EbookRatingInsert {
  final int rating;
  final int ebookId;

  const EbookRatingInsert({
    required this.rating,
    required this.ebookId,
  });

  factory EbookRatingInsert.fromJson(Map<String, dynamic> json) =>
      _$EbookRatingInsertFromJson(json);

  Map<String, dynamic> toJson() => _$EbookRatingInsertToJson(this);
}
