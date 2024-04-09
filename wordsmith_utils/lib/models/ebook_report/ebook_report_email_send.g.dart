// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_report_email_send.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookReportEmailSend _$EbookReportEmailSendFromJson(
        Map<String, dynamic> json) =>
    EbookReportEmailSend(
      reportId: json['reportId'] as int,
      body: json['body'] as String,
    );

Map<String, dynamic> _$EbookReportEmailSendToJson(
        EbookReportEmailSend instance) =>
    <String, dynamic>{
      'reportId': instance.reportId,
      'body': instance.body,
    };
