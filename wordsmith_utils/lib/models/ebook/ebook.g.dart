// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ebook _$EbookFromJson(Map<String, dynamic> json) => Ebook(
      json['id'] as int,
      json['title'] as String,
      json['description'] as String,
      (json['ratingAverage'] as num?)?.toDouble(),
      DateTime.parse(json['publishedDate'] as String),
      DateTime.parse(json['updatedDate'] as String),
      (json['price'] as num?)?.toDouble(),
      json['chapterCount'] as int,
      json['path'] as String,
      User.fromJson(json['author'] as Map<String, dynamic>),
      Image.fromJson(json['coverArt'] as Map<String, dynamic>),
      json['genres'] as String,
      MaturityRating.fromJson(json['maturityRating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EbookToJson(Ebook instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'ratingAverage': instance.ratingAverage,
      'publishedDate': instance.publishedDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
      'price': instance.price,
      'chapterCount': instance.chapterCount,
      'path': instance.path,
      'author': instance.author,
      'coverArt': instance.coverArt,
      'genres': instance.genres,
      'maturityRating': instance.maturityRating,
    };
