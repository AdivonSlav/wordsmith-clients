// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageInsert _$ImageInsertFromJson(Map<String, dynamic> json) => ImageInsert(
      json['encodedImage'] as String,
      json['format'] as String,
      json['size'] as int?,
    );

Map<String, dynamic> _$ImageInsertToJson(ImageInsert instance) =>
    <String, dynamic>{
      'encodedImage': instance.encodedImage,
      'format': instance.format,
      'size': instance.size,
    };
