import 'package:json_annotation/json_annotation.dart';

part "app_report_insert.g.dart";

@JsonSerializable(createFactory: false)
class AppReportInsert {
  final String content;

  const AppReportInsert({required this.content});

  Map<String, dynamic> toJson() => _$AppReportInsertToJson(this);
}
