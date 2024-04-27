import 'package:json_annotation/json_annotation.dart';

part "statistics_request.g.dart";

@JsonSerializable(createFactory: false)
class StatisticsRequest {
  final DateTime startDate;
  final DateTime endDate;

  const StatisticsRequest({
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => _$StatisticsRequestToJson(this);
}
