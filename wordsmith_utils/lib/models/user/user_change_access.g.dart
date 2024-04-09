// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_change_access.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserChangeAccess _$UserChangeAccessFromJson(Map<String, dynamic> json) =>
    UserChangeAccess(
      allowedAccess: json['allowedAccess'] as bool,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
    );

Map<String, dynamic> _$UserChangeAccessToJson(UserChangeAccess instance) =>
    <String, dynamic>{
      'allowedAccess': instance.allowedAccess,
      'expiryDate': instance.expiryDate?.toIso8601String(),
    };
