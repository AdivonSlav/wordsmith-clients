// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_library_category_add.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLibraryCategoryAdd _$UserLibraryCategoryAddFromJson(
        Map<String, dynamic> json) =>
    UserLibraryCategoryAdd(
      (json['userLibraryIds'] as List<dynamic>).map((e) => e as int).toList(),
      json['userLibraryCategoryId'] as int?,
      json['newCategoryName'] as String?,
    );

Map<String, dynamic> _$UserLibraryCategoryAddToJson(
        UserLibraryCategoryAdd instance) =>
    <String, dynamic>{
      'userLibraryIds': instance.userLibraryIds,
      'userLibraryCategoryId': instance.userLibraryCategoryId,
      'newCategoryName': instance.newCategoryName,
    };
