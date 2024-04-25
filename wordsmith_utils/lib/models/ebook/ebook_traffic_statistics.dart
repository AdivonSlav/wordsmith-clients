import 'package:json_annotation/json_annotation.dart';

part "ebook_traffic_statistics.g.dart";

@JsonSerializable(createToJson: false)
class EbookTrafficStatistics {
  final int id;
  final String title;
  final int syncCount;

  const EbookTrafficStatistics(this.id, this.title, this.syncCount);

  factory EbookTrafficStatistics.fromJson(Map<String, dynamic> json) =>
      _$EbookTrafficStatisticsFromJson(json);
}
