import 'package:json_annotation/json_annotation.dart';

part "ebook_rating_update.g.dart";

@JsonSerializable()
class EbookRatingUpdate {
  final int rating;

  const EbookRatingUpdate({required this.rating});

  factory EbookRatingUpdate.fromJson(Map<String, dynamic> json) =>
      _$EbookRatingUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$EbookRatingUpdateToJson(this);
}
