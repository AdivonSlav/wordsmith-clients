import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/report/report_reason.dart";
import "package:wordsmith_utils/models/user/user.dart";

part "report_details.g.dart";

@JsonSerializable()
class ReportDetails {
  final int id;
  final String content;
  final DateTime submissionDate;
  final bool isClosed;
  final User reporter;
  final ReportReason reportReason;

  ReportDetails(this.id, this.content, this.submissionDate, this.isClosed,
      this.reporter, this.reportReason);

  factory ReportDetails.fromJson(Map<String, dynamic> json) =>
      _$ReportDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDetailsToJson(this);
}
