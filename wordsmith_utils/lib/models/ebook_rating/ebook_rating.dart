import 'package:json_annotation/json_annotation.dart';

part "ebook_rating.g.dart";

@JsonSerializable()
class EbookRating {
  final int id;
  final int rating;
  final DateTime ratingDate;
  final int eBookId;
  final int userId;

  const EbookRating(
    this.id,
    this.rating,
    this.ratingDate,
    this.eBookId,
    this.userId,
  );

  factory EbookRating.fromJson(Map<String, dynamic> json) =>
      _$EbookRatingFromJson(json);

  Map<String, dynamic> toJson() => _$EbookRatingToJson(this);
}
