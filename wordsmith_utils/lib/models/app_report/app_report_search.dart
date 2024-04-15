import 'package:json_annotation/json_annotation.dart';

part "app_report_search.g.dart";

@JsonSerializable(createFactory: false)
class AppReportSearch {
  final int? userId;
  final bool? isClosed;
  final DateTime? startDate;
  final DateTime? endDate;

  const AppReportSearch({
    this.userId,
    this.isClosed,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => _$AppReportSearchToJson(this);
}
