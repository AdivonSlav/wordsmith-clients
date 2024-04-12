// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStatistics _$UserStatisticsFromJson(Map<String, dynamic> json) =>
    UserStatistics(
      json['publishedBooksCount'] as int,
      json['favoriteBooksCount'] as int,
    );

Map<String, dynamic> _$UserStatisticsToJson(UserStatistics instance) =>
    <String, dynamic>{
      'publishedBooksCount': instance.publishedBooksCount,
      'favoriteBooksCount': instance.favoriteBooksCount,
    };
