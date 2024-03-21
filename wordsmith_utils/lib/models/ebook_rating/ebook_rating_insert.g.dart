// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_rating_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookRatingInsert _$EbookRatingInsertFromJson(Map<String, dynamic> json) =>
    EbookRatingInsert(
      rating: json['rating'] as int,
      ebookId: json['ebookId'] as int,
    );

Map<String, dynamic> _$EbookRatingInsertToJson(EbookRatingInsert instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'ebookId': instance.ebookId,
    };
