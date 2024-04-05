import 'package:json_annotation/json_annotation.dart';

part "ebook_report_search.g.dart";

@JsonSerializable(createFactory: false)
class EbookReportSearch {
  final int? reportedEBookId;
  final bool? isClosed;
  final String? reason;
  final DateTime? startDate;
  final DateTime? endDate;

  const EbookReportSearch({
    this.reportedEBookId,
    this.isClosed,
    this.reason,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => _$EbookReportSearchToJson(this);
}
