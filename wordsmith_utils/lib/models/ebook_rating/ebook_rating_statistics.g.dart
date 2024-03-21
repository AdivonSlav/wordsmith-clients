// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_rating_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookRatingStatistics _$EbookRatingStatisticsFromJson(
        Map<String, dynamic> json) =>
    EbookRatingStatistics(
      json['eBookId'] as int,
      (json['ratingAverage'] as num).toDouble(),
      json['totalRatingCount'] as int,
      (json['ratingCounts'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as int),
      ),
    );

Map<String, dynamic> _$EbookRatingStatisticsToJson(
        EbookRatingStatistics instance) =>
    <String, dynamic>{
      'eBookId': instance.eBookId,
      'ratingAverage': instance.ratingAverage,
      'totalRatingCount': instance.totalRatingCount,
      'ratingCounts':
          instance.ratingCounts.map((k, e) => MapEntry(k.toString(), e)),
    };
