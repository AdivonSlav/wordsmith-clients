import 'package:json_annotation/json_annotation.dart';

part "user_report_update.g.dart";

@JsonSerializable()
class UserReportUpdate {
  final bool isClosed;

  const UserReportUpdate({required this.isClosed});

  factory UserReportUpdate.fromJson(Map<String, dynamic> json) =>
      _$UserReportUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$UserReportUpdateToJson(this);
}
