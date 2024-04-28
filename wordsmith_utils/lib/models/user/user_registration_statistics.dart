import 'package:json_annotation/json_annotation.dart';

part "user_registration_statistics.g.dart";

@JsonSerializable(createToJson: false)
class UserRegistrationStatistics {
  // final int year;
  // final int month;
  final DateTime date;
  final int registrationCount;

  const UserRegistrationStatistics(
    this.date,
    this.registrationCount,
  );

  factory UserRegistrationStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserRegistrationStatisticsFromJson(json);
}
