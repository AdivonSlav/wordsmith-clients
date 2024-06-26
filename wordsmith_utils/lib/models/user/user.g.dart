// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['id'] as int,
      json['username'] as String,
      json['email'] as String,
      json['profileImage'] == null
          ? null
          : Image.fromJson(json['profileImage'] as Map<String, dynamic>),
      DateTime.parse(json['registrationDate'] as String),
      $enumDecode(_$UserStatusEnumMap, json['status']),
      json['about'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'profileImage': instance.profileImage,
      'registrationDate': instance.registrationDate.toIso8601String(),
      'status': _$UserStatusEnumMap[instance.status]!,
      'about': instance.about,
    };

const _$UserStatusEnumMap = {
  UserStatus.active: 'Active',
  UserStatus.temporarilyBanned: 'TemporarilyBanned',
  UserStatus.banned: 'Banned',
};
