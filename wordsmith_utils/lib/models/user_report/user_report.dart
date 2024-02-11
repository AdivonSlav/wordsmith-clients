import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/report/report_details.dart";
import "package:wordsmith_utils/models/user/user.dart";

part "user_report.g.dart";

@JsonSerializable()
class UserReport {
  final int id;
  final User reportedUser;
  final ReportDetails reportDetails;

  UserReport(this.id, this.reportedUser, this.reportDetails);

  factory UserReport.fromJson(Map<String, dynamic> json) =>
      _$UserReportFromJson(json);

  Map<String, dynamic> toJson() => _$UserReportToJson(this);
}
