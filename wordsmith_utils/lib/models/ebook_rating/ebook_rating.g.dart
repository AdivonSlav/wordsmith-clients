// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookRating _$EbookRatingFromJson(Map<String, dynamic> json) => EbookRating(
      json['id'] as int,
      json['rating'] as int,
      DateTime.parse(json['ratingDate'] as String),
      json['ebookId'] as int,
      json['userId'] as int,
    );

Map<String, dynamic> _$EbookRatingToJson(EbookRating instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'ratingDate': instance.ratingDate.toIso8601String(),
      'ebookId': instance.ebookId,
      'userId': instance.userId,
    };
