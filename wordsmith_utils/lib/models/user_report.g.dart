// GENERATED CODE - DO NOT MODIFY BY HAND

part of "user_report.dart";

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReport _$UserReportFromJson(Map<String, dynamic> json) => UserReport(
      json["id"] as int,
      User.fromJson(json["reportedUser"] as Map<String, dynamic>),
      ReportDetails.fromJson(json["reportDetails"] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserReportToJson(UserReport instance) =>
    <String, dynamic>{
      "id": instance.id,
      "reportedUser": instance.reportedUser,
      "reportDetails": instance.reportDetails,
    };
