// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLogin _$UserLoginFromJson(Map<String, dynamic> json) => UserLogin(
      json['accessToken'] as String?,
      json['refreshToken'] as String?,
      json['expiresIn'] == null
          ? null
          : DateTime.parse(json['expiresIn'] as String),
      User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserLoginToJson(UserLogin instance) => <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn?.toIso8601String(),
      'user': instance.user,
    };
