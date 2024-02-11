// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInsert _$UserInsertFromJson(Map<String, dynamic> json) => UserInsert(
      json['username'] as String,
      json['email'] as String,
      json['password'] as String,
      json['confirmPassword'] as String,
      json['profileImage'] == null
          ? null
          : ImageInsert.fromJson(json['profileImage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserInsertToJson(UserInsert instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'profileImage': instance.profileImage,
    };
