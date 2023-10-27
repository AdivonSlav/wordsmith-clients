import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/user.dart";

part "report_details.g.dart";

@JsonSerializable()
class ReportDetails {
  final int id;
  final String content;
  final DateTime submissionDate;
  final bool isClosed;
  final User reporter;

  ReportDetails(
      this.id, this.content, this.submissionDate, this.isClosed, this.reporter);

  factory ReportDetails.fromJson(Map<String, dynamic> json) =>
      _$ReportDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDetailsToJson(this);
}
