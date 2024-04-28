import 'package:json_annotation/json_annotation.dart';

part "ebook_publish_statistics.g.dart";

@JsonSerializable(createToJson: false)
class EbookPublishStatistics {
  final DateTime date;
  final int publishCount;

  const EbookPublishStatistics(this.date, this.publishCount);

  factory EbookPublishStatistics.fromJson(Map<String, dynamic> json) =>
      _$EbookPublishStatisticsFromJson(json);
}
