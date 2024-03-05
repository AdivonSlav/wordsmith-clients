// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLibrary _$UserLibraryFromJson(Map<String, dynamic> json) => UserLibrary(
      json['id'] as int,
      json['eBookId'] as int,
      json['userId'] as int,
      DateTime.parse(json['syncDate'] as String),
      json['isRead'] as bool,
      json['readProgress'] as String,
      json['userLibraryCategoryId'] as int?,
      json['lastChapterId'] as int,
      json['lastPage'] as int,
      Ebook.fromJson(json['eBook'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserLibraryToJson(UserLibrary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eBookId': instance.eBookId,
      'userId': instance.userId,
      'eBook': instance.eBook,
      'syncDate': instance.syncDate.toIso8601String(),
      'isRead': instance.isRead,
      'readProgress': instance.readProgress,
      'userLibraryCategoryId': instance.userLibraryCategoryId,
      'lastChapterId': instance.lastChapterId,
      'lastPage': instance.lastPage,
    };
