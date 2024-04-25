import 'package:json_annotation/json_annotation.dart';

part "ebook_publish_statistics.g.dart";

@JsonSerializable(createToJson: false)
class EbookPublishStatistics {
  final int year;
  final String month;
  final int publishCount;

  const EbookPublishStatistics(this.year, this.month, this.publishCount);

  factory EbookPublishStatistics.fromJson(Map<String, dynamic> json) =>
      _$EbookPublishStatisticsFromJson(json);
}
