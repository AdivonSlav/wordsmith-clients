// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_report_email_send.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReportEmailSend _$UserReportEmailSendFromJson(Map<String, dynamic> json) =>
    UserReportEmailSend(
      reportId: json['reportId'] as int,
      body: json['body'] as String,
    );

Map<String, dynamic> _$UserReportEmailSendToJson(
        UserReportEmailSend instance) =>
    <String, dynamic>{
      'reportId': instance.reportId,
      'body': instance.body,
    };
