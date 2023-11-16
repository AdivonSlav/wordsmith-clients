import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/ebook.dart";
import "package:wordsmith_utils/models/report_details.dart";

part "ebook_report.g.dart";

@JsonSerializable()
class EBookReport {
  final int id;
  final EBook reportedEBook;
  final ReportDetails reportDetails;

  EBookReport(this.id, this.reportedEBook, this.reportDetails);

  factory EBookReport.fromJson(Map<String, dynamic> json) =>
      _$EBookReportFromJson(json);

  Map<String, dynamic> toJson() => _$EBookReportToJson(this);
}
