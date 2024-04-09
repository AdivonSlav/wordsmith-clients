import 'package:json_annotation/json_annotation.dart';

enum UserStatus {
  @JsonValue("Active")
  active,
  @JsonValue("TemporarilyBanned")
  temporarilyBanned,
  @JsonValue("Banned")
  banned,
}
