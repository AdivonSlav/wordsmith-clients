import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/report/report_type.dart";

part "report_reason.g.dart";

@JsonSerializable()
class ReportReason {
  final int id;
  final String reason;
  final ReportType type;

  ReportReason(this.id, this.reason, this.type);

  factory ReportReason.fromJson(Map<String, dynamic> json) =>
      _$ReportReasonFromJson(json);

  Map<String, dynamic> toJson() => _$ReportReasonToJson(this);
}
