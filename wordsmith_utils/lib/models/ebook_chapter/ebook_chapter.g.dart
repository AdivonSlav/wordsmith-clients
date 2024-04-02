// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookChapter _$EbookChapterFromJson(Map<String, dynamic> json) => EbookChapter(
      json['id'] as int,
      json['chapterName'] as String,
      json['chapterNumber'] as int,
      json['eBookId'] as int,
    );

Map<String, dynamic> _$EbookChapterToJson(EbookChapter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chapterName': instance.chapterName,
      'chapterNumber': instance.chapterNumber,
      'eBookId': instance.eBookId,
    };
