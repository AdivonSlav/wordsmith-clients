// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdate _$UserUpdateFromJson(Map<String, dynamic> json) => UserUpdate(
      username: json['username'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      oldPassword: json['oldPassword'] as String?,
      profileImage: json['profileImage'] == null
          ? null
          : ImageInsert.fromJson(json['profileImage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserUpdateToJson(UserUpdate instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'oldPassword': instance.oldPassword,
      'profileImage': instance.profileImage,
    };
