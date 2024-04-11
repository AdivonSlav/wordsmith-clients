// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_report_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookReportInsert _$EbookReportInsertFromJson(Map<String, dynamic> json) =>
    EbookReportInsert(
      reportedEBookId: json['reportedEBookId'] as int,
      content: json['content'] as String,
      reportReasonId: json['reportReasonId'] as int,
    );

Map<String, dynamic> _$EbookReportInsertToJson(EbookReportInsert instance) =>
    <String, dynamic>{
      'reportedEBookId': instance.reportedEBookId,
      'content': instance.content,
      'reportReasonId': instance.reportReasonId,
    };
