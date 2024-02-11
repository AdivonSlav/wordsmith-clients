// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_parse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EBookParse _$EBookParseFromJson(Map<String, dynamic> json) => EBookParse(
      json['title'] as String,
      json['description'] as String,
      json['encodedCoverArt'] as String,
      (json['chapters'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$EBookParseToJson(EBookParse instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'encodedCoverArt': instance.encodedCoverArt,
      'chapters': instance.chapters,
    };
