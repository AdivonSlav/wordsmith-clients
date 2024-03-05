// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookInsert _$EbookInsertFromJson(Map<String, dynamic> json) => EbookInsert(
      json['title'] as String,
      json['description'] as String,
      json['encodedCoverArt'] as String,
      (json['chapters'] as List<dynamic>).map((e) => e as String).toList(),
      (json['price'] as num?)?.toDouble(),
      json['authorId'] as int,
      (json['genreIds'] as List<dynamic>).map((e) => e as int).toList(),
      json['maturityRatingId'] as int,
    );

Map<String, dynamic> _$EbookInsertToJson(EbookInsert instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'encodedCoverArt': instance.encodedCoverArt,
      'chapters': instance.chapters,
      'price': instance.price,
      'authorId': instance.authorId,
      'genreIds': instance.genreIds,
      'maturityRatingId': instance.maturityRatingId,
    };
