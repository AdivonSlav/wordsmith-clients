import 'package:json_annotation/json_annotation.dart';

enum ReportType {
  @JsonValue("User")
  user,
  @JsonValue("Ebook")
  ebook,
}
