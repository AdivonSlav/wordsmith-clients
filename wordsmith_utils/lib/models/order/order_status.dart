import 'package:json_annotation/json_annotation.dart';

enum OrderStatus {
  @JsonValue("Pending")
  pending,
  @JsonValue("Completed")
  completed,
  @JsonValue("Refunded")
  refunded,
}
