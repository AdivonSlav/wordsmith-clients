import 'package:flutter/material.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/order/order.dart';

class EbookPurchaseSuccessWidget extends StatefulWidget {
  final Order order;

  const EbookPurchaseSuccessWidget({super.key, required this.order});

  @override
  State<EbookPurchaseSuccessWidget> createState() =>
      _EbookPurchaseSuccessWidgetState();
}

class _EbookPurchaseSuccessWidgetState
    extends State<EbookPurchaseSuccessWidget> {
  String _getPaymentDate() {
    return formatDateTime(date: widget.order.paymentDate!, format: "yMMMMd");
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Thank you for the purchase!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "Details",
                textAlign: TextAlign.end,
                style: theme.textTheme.labelLarge,
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Ref. ID: ${widget.order.referenceId}"),
                    const SizedBox(height: 4.0),
                    Text("PayPal Order ID: ${widget.order.payPalOrderId}"),
                    const SizedBox(height: 4.0),
                    Text("Date of purchase: ${_getPaymentDate()}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Align(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Go back"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
