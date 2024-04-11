import 'package:json_annotation/json_annotation.dart';
import 'package:wordsmith_utils/models/report/report_type.dart';

part "report_reason_search.g.dart";

@JsonSerializable(createFactory: false)
class ReportReasonSearch {
  final ReportType type;

  const ReportReasonSearch({required this.type});

  Map<String, dynamic> toJson() => _$ReportReasonSearchToJson(this);
}
