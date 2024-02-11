// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image _$ImageFromJson(Map<String, dynamic> json) => Image(
      json['imagePath'] as String?,
      json['encodedImage'] as String?,
      json['format'] as String,
      json['size'] as int,
    );

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'imagePath': instance.imagePath,
      'encodedImage': instance.encodedImage,
      'format': instance.format,
      'size': instance.size,
    };
