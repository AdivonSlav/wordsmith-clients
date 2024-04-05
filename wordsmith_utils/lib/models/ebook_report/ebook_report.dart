import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/ebook/ebook.dart";
import "package:wordsmith_utils/models/report/report_details.dart";

part "ebook_report.g.dart";

@JsonSerializable()
class EbookReport {
  final int id;
  final Ebook reportedEBook;
  final ReportDetails reportDetails;

  EbookReport(this.id, this.reportedEBook, this.reportDetails);

  factory EbookReport.fromJson(Map<String, dynamic> json) =>
      _$EbookReportFromJson(json);

  Map<String, dynamic> toJson() => _$EbookReportToJson(this);
}
