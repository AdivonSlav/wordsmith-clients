// GENERATED CODE - DO NOT MODIFY BY HAND

part of "report_details.dart";

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDetails _$ReportDetailsFromJson(Map<String, dynamic> json) =>
    ReportDetails(
      json["id"] as int,
      json["content"] as String,
      DateTime.parse(json["submissionDate"] as String),
      json["isClosed"] as bool,
      User.fromJson(json["reporter"] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReportDetailsToJson(ReportDetails instance) =>
    <String, dynamic>{
      "id": instance.id,
      "content": instance.content,
      "submissionDate": instance.submissionDate.toIso8601String(),
      "isClosed": instance.isClosed,
      "reporter": instance.reporter,
    };
