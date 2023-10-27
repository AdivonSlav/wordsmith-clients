import "package:json_annotation/json_annotation.dart";

part "report_reason.g.dart";

@JsonSerializable()
class ReportReason {
  final int id;
  final String reason;
  final String subject;

  ReportReason(this.id, this.reason, this.subject);

  factory ReportReason.fromJson(Map<String, dynamic> json) =>
      _$ReportReasonFromJson(json);

  Map<String, dynamic> toJson() => _$ReportReasonToJson(this);
}
