// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookReport _$EbookReportFromJson(Map<String, dynamic> json) => EbookReport(
      json['id'] as int,
      Ebook.fromJson(json['reportedEbook'] as Map<String, dynamic>),
      ReportDetails.fromJson(json['reportDetails'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EbookReportToJson(EbookReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportedEbook': instance.reportedEbook,
      'reportDetails': instance.reportDetails,
    };
