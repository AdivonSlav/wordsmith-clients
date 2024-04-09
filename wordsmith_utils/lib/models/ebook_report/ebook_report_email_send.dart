import 'package:json_annotation/json_annotation.dart';

part "ebook_report_email_send.g.dart";

@JsonSerializable()
class EbookReportEmailSend {
  final int reportId;
  final String body;

  const EbookReportEmailSend({
    required this.reportId,
    required this.body,
  });

  factory EbookReportEmailSend.fromJson(Map<String, dynamic> json) =>
      _$EbookReportEmailSendFromJson(json);

  Map<String, dynamic> toJson() => _$EbookReportEmailSendToJson(this);
}
