// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_library_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLibraryCategory _$UserLibraryCategoryFromJson(Map<String, dynamic> json) =>
    UserLibraryCategory(
      json['id'] as int,
      json['userId'] as int,
      json['name'] as String,
    );

Map<String, dynamic> _$UserLibraryCategoryToJson(
        UserLibraryCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
    };
