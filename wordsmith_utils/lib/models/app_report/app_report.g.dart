// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppReport _$AppReportFromJson(Map<String, dynamic> json) => AppReport(
      json['id'] as int,
      User.fromJson(json['user'] as Map<String, dynamic>),
      DateTime.parse(json['submissionDate'] as String),
      json['content'] as String,
      json['isClosed'] as bool,
    );

Map<String, dynamic> _$AppReportToJson(AppReport instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'submissionDate': instance.submissionDate.toIso8601String(),
      'content': instance.content,
      'isClosed': instance.isClosed,
    };
