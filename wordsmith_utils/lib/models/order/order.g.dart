// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['id'] as int,
      referenceId: json['referenceId'] as String,
      payPalOrderId: json['payPalOrderId'] as String,
      payPalCaptureId: json['payPalCaptureId'] as String?,
      payPalRefundId: json['payPalRefundId'] as String?,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      payerId: json['payerId'] as int?,
      payerUsername: json['payerUsername'] as String,
      payeeId: json['payeeId'] as int?,
      payeeUsername: json['payeeUsername'] as String,
      payeePayPalEmail: json['payeePayPalEmail'] as String,
      eBookId: json['eBookId'] as int?,
      eBookTitle: json['eBookTitle'] as String,
      orderCreationDate: DateTime.parse(json['orderCreationDate'] as String),
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.parse(json['paymentDate'] as String),
      refundDate: json['refundDate'] == null
          ? null
          : DateTime.parse(json['refundDate'] as String),
      paymentAmount: (json['paymentAmount'] as num).toDouble(),
      paymentUrl: json['paymentUrl'] as String,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'referenceId': instance.referenceId,
      'payPalOrderId': instance.payPalOrderId,
      'payPalCaptureId': instance.payPalCaptureId,
      'payPalRefundId': instance.payPalRefundId,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'payerId': instance.payerId,
      'payerUsername': instance.payerUsername,
      'payeeId': instance.payeeId,
      'payeeUsername': instance.payeeUsername,
      'payeePayPalEmail': instance.payeePayPalEmail,
      'eBookId': instance.eBookId,
      'eBookTitle': instance.eBookTitle,
      'orderCreationDate': instance.orderCreationDate.toIso8601String(),
      'paymentDate': instance.paymentDate?.toIso8601String(),
      'refundDate': instance.refundDate?.toIso8601String(),
      'paymentAmount': instance.paymentAmount,
      'paymentUrl': instance.paymentUrl,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'Pending',
  OrderStatus.completed: 'Completed',
  OrderStatus.refunded: 'Refunded',
};
