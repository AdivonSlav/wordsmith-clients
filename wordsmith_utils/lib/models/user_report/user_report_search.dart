import 'package:json_annotation/json_annotation.dart';

part "user_report_search.g.dart";

@JsonSerializable(createFactory: false)
class UserReportSearch {
  final int? reportedUserId;
  final bool? isClosed;
  final String? reason;
  final DateTime? reportDate;

  const UserReportSearch({
    this.reportedUserId,
    this.isClosed,
    this.reason,
    this.reportDate,
  });

  Map<String, dynamic> toJson() => _$UserReportSearchToJson(this);
}
