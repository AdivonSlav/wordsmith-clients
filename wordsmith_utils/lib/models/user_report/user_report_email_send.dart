import 'package:json_annotation/json_annotation.dart';

part "user_report_email_send.g.dart";

@JsonSerializable()
class UserReportEmailSend {
  final int reportId;
  final String body;

  const UserReportEmailSend({
    required this.reportId,
    required this.body,
  });

  factory UserReportEmailSend.fromJson(Map<String, dynamic> json) =>
      _$UserReportEmailSendFromJson(json);

  Map<String, dynamic> toJson() => _$UserReportEmailSendToJson(this);
}
