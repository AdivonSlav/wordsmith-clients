// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_report_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$UserReportSearchToJson(UserReportSearch instance) =>
    <String, dynamic>{
      'reportedUserId': instance.reportedUserId,
      'isClosed': instance.isClosed,
      'reason': instance.reason,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
    };
