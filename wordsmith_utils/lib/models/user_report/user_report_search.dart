import 'package:json_annotation/json_annotation.dart';

part "user_report_search.g.dart";

@JsonSerializable(createFactory: false)
class UserReportSearch {
  final int? reportedUserId;
  final bool? isClosed;
  final String? reason;
  final DateTime? startDate;
  final DateTime? endDate;

  const UserReportSearch({
    this.reportedUserId,
    this.isClosed,
    this.reason,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => _$UserReportSearchToJson(this);
}
