import 'package:json_annotation/json_annotation.dart';
import 'package:wordsmith_utils/models/user/user.dart';

part "app_report.g.dart";

@JsonSerializable()
class AppReport {
  final int id;
  final User user;
  final DateTime submissionDate;
  final String content;
  final bool isClosed;

  const AppReport(
    this.id,
    this.user,
    this.submissionDate,
    this.content,
    this.isClosed,
  );

  factory AppReport.fromJson(Map<String, dynamic> json) =>
      _$AppReportFromJson(json);

  Map<String, dynamic> toJson() => _$AppReportToJson(this);
}
