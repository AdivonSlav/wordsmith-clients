// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_library_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLibraryInsert _$UserLibraryInsertFromJson(Map<String, dynamic> json) =>
    UserLibraryInsert(
      eBookId: json['eBookId'] as int,
      orderReferenceId: json['orderReferenceId'] as String?,
    );

Map<String, dynamic> _$UserLibraryInsertToJson(UserLibraryInsert instance) =>
    <String, dynamic>{
      'eBookId': instance.eBookId,
      'orderReferenceId': instance.orderReferenceId,
    };
