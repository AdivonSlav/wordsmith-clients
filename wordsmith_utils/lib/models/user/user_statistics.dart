import 'package:json_annotation/json_annotation.dart';

part "user_statistics.g.dart";

@JsonSerializable()
class UserStatistics {
  final int publishedBooksCount;
  final int favoriteBooksCount;

  const UserStatistics(this.publishedBooksCount, this.favoriteBooksCount);

  factory UserStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatisticsToJson(this);
}
