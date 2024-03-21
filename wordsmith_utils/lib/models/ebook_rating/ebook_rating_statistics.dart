import 'package:json_annotation/json_annotation.dart';

part "ebook_rating_statistics.g.dart";

@JsonSerializable()
class EbookRatingStatistics {
  final int eBookId;
  final double ratingAverage;
  final int totalRatingCount;
  final Map<int, int> ratingCounts;

  const EbookRatingStatistics(
    this.eBookId,
    this.ratingAverage,
    this.totalRatingCount,
    this.ratingCounts,
  );

  factory EbookRatingStatistics.fromJson(Map<String, dynamic> json) =>
      _$EbookRatingStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$EbookRatingStatisticsToJson(this);
}
