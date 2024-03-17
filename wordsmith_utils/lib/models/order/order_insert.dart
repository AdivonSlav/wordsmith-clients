import 'package:json_annotation/json_annotation.dart';

part "order_insert.g.dart";

@JsonSerializable()
class OrderInsert {
  final int ebookId;

  const OrderInsert(this.ebookId);

  factory OrderInsert.fromJson(Map<String, dynamic> json) =>
      _$OrderInsertFromJson(json);

  Map<String, dynamic> toJson() => _$OrderInsertToJson(this);
}
