// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_parse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookParse _$EbookParseFromJson(Map<String, dynamic> json) => EbookParse(
      json['title'] as String,
      json['description'] as String,
      json['encodedCoverArt'] as String,
      (json['chapters'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$EbookParseToJson(EbookParse instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'encodedCoverArt': instance.encodedCoverArt,
      'chapters': instance.chapters,
    };
