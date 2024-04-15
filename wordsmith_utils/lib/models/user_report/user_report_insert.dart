import 'package:json_annotation/json_annotation.dart';

part "user_report_insert.g.dart";

@JsonSerializable(createFactory: false)
class UserReportInsert {
  final int reportedUserId;
  final String content;
  final int reportReasonId;

  const UserReportInsert({
    required this.reportedUserId,
    required this.content,
    required this.reportReasonId,
  });

  Map<String, dynamic> toJson() => _$UserReportInsertToJson(this);
}
