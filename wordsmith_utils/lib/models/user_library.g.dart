// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLibrary _$UserLibraryFromJson(Map<String, dynamic> json) => UserLibrary(
      json['eBookId'] as int,
      json['userId'] as int,
      DateTime.parse(json['syncDate'] as String),
      json['isRead'] as bool,
      json['readProgress'] as String?,
      json['lastChapterId'] as int,
      json['lastPage'] as int,
    );

Map<String, dynamic> _$UserLibraryToJson(UserLibrary instance) =>
    <String, dynamic>{
      'eBookId': instance.eBookId,
      'userId': instance.userId,
      'syncDate': instance.syncDate.toIso8601String(),
      'isRead': instance.isRead,
      'readProgress': instance.readProgress,
      'lastChapterId': instance.lastChapterId,
      'lastPage': instance.lastPage,
    };
