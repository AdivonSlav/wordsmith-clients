import 'package:json_annotation/json_annotation.dart';

part "ebook_report_insert.g.dart";

@JsonSerializable()
class EbookReportInsert {
  final int reportedEBookId;
  final String content;
  final int reportReasonId;

  const EbookReportInsert({
    required this.reportedEBookId,
    required this.content,
    required this.reportReasonId,
  });

  factory EbookReportInsert.fromJson(Map<String, dynamic> json) =>
      _$EbookReportInsertFromJson(json);

  Map<String, dynamic> toJson() => _$EbookReportInsertToJson(this);
}
