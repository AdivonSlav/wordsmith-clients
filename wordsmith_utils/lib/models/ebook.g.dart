// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EBook _$EBookFromJson(Map<String, dynamic> json) => EBook(
      json['id'] as int,
      json['title'] as String,
      json['description'] as String,
      (json['ratingAverage'] as num?)?.toDouble(),
      DateTime.parse(json['publishedDate'] as String),
      DateTime.parse(json['updatedDate'] as String),
      (json['price'] as num?)?.toDouble(),
      json['chapterCount'] as int,
      json['path'] as String,
      Image.fromJson(json['coverArt'] as Map<String, dynamic>),
      Genre.fromJson(json['genre'] as Map<String, dynamic>),
      MaturityRating.fromJson(json['maturityRating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EBookToJson(EBook instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'ratingAverage': instance.ratingAverage,
      'publishedDate': instance.publishedDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
      'price': instance.price,
      'chapterCount': instance.chapterCount,
      'path': instance.path,
      'coverArt': instance.coverArt,
      'genre': instance.genre,
      'maturityRating': instance.maturityRating,
    };
