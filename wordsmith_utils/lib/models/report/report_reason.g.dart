// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_reason.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportReason _$ReportReasonFromJson(Map<String, dynamic> json) => ReportReason(
      json['id'] as int,
      json['reason'] as String,
      $enumDecode(_$ReportTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$ReportReasonToJson(ReportReason instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reason': instance.reason,
      'type': _$ReportTypeEnumMap[instance.type]!,
    };

const _$ReportTypeEnumMap = {
  ReportType.user: 'User',
  ReportType.ebook: 'Ebook',
};
