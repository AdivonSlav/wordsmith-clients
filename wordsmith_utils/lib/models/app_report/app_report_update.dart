import 'package:json_annotation/json_annotation.dart';

part "app_report_update.g.dart";

@JsonSerializable(createFactory: false)
class AppReportUpdate {
  final bool isClosed;

  const AppReportUpdate({required this.isClosed});

  Map<String, dynamic> toJson() => _$AppReportUpdateToJson(this);
}
