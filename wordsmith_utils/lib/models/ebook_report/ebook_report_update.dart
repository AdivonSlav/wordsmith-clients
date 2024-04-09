import 'package:json_annotation/json_annotation.dart';

part "ebook_report_update.g.dart";

@JsonSerializable()
class EbookReportUpdate {
  final bool isClosed;

  const EbookReportUpdate({required this.isClosed});

  factory EbookReportUpdate.fromJson(Map<String, dynamic> json) =>
      _$EbookReportUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$EbookReportUpdateToJson(this);
}
