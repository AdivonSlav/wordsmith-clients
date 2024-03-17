import 'package:json_annotation/json_annotation.dart';
import 'package:wordsmith_utils/models/order/order_status.dart';

part "order.g.dart";

@JsonSerializable()
class Order {
  final int id;
  final String referenceId;
  final String payPalOrderId;
  final String payPalCaptureId;
  final String payPalRefundId;
  final OrderStatus status;
  final int? payerId;
  final String payerUsername;
  final int? payeeId;
  final String payeeUsername;
  final String payeePayPalEmail;
  final int? eBookId;
  final String eBookTitle;
  final DateTime orderCreationDate;
  final DateTime? paymentDate;
  final DateTime? refundDate;
  final double paymentAmount;
  final String paymentUrl;

  const Order({
    required this.id,
    required this.referenceId,
    required this.payPalOrderId,
    required this.payPalCaptureId,
    required this.payPalRefundId,
    required this.status,
    required this.payerId,
    required this.payerUsername,
    required this.payeeId,
    required this.payeeUsername,
    required this.payeePayPalEmail,
    required this.eBookId,
    required this.eBookTitle,
    required this.orderCreationDate,
    required this.paymentDate,
    required this.refundDate,
    required this.paymentAmount,
    required this.paymentUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
