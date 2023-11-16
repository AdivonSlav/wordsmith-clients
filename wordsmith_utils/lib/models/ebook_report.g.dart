// GENERATED CODE - DO NOT MODIFY BY HAND

part of "ebook_report.dart";

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EBookReport _$EBookReportFromJson(Map<String, dynamic> json) => EBookReport(
      json["id"] as int,
      EBook.fromJson(json["reportedEBook"] as Map<String, dynamic>),
      ReportDetails.fromJson(json["reportDetails"] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EBookReportToJson(EBookReport instance) =>
    <String, dynamic>{
      "id": instance.id,
      "reportedEBook": instance.reportedEBook,
      "reportDetails": instance.reportDetails,
    };
