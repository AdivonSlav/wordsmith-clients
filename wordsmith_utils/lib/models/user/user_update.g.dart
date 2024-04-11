// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdate _$UserUpdateFromJson(Map<String, dynamic> json) => UserUpdate(
      username: json['username'] as String,
      email: json['email'] as String,
      about: json['about'] as String,
      password: json['password'] as String?,
      oldPassword: json['oldPassword'] as String?,
    );

Map<String, dynamic> _$UserUpdateToJson(UserUpdate instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'about': instance.about,
      'password': instance.password,
      'oldPassword': instance.oldPassword,
    };
