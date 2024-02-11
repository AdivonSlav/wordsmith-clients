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
      User.fromJson(json['author'] as Map<String, dynamic>),
      Image.fromJson(json['coverArt'] as Map<String, dynamic>),
      json['genres'] as String,
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
      'author': instance.author,
      'coverArt': instance.coverArt,
      'genres': instance.genres,
      'maturityRating': instance.maturityRating,
    };
