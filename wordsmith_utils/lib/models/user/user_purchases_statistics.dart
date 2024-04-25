import 'package:json_annotation/json_annotation.dart';

part "user_purchases_statistics.g.dart";

@JsonSerializable(createToJson: false)
class UserPurchasesStatistics {
  final String username;
  final int purchaseCount;
  final double totalSpent;

  const UserPurchasesStatistics(
    this.username,
    this.purchaseCount,
    this.totalSpent,
  );

  factory UserPurchasesStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserPurchasesStatisticsFromJson(json);
}
