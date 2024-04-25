// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_purchases_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPurchasesStatistics _$UserPurchasesStatisticsFromJson(
        Map<String, dynamic> json) =>
    UserPurchasesStatistics(
      json['username'] as String,
      json['purchaseCount'] as int,
      (json['totalSpent'] as num).toDouble(),
    );
