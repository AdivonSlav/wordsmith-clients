// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_library_category_remove.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLibraryCategoryRemove _$UserLibraryCategoryRemoveFromJson(
        Map<String, dynamic> json) =>
    UserLibraryCategoryRemove(
      userLibraryIds: (json['userLibraryIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );

Map<String, dynamic> _$UserLibraryCategoryRemoveToJson(
        UserLibraryCategoryRemove instance) =>
    <String, dynamic>{
      'userLibraryIds': instance.userLibraryIds,
    };
