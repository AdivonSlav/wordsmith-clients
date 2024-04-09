import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_purchase_success.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/formatters/number_formatter.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/entity_result.dart';
import 'package:wordsmith_utils/models/order/order.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
import 'package:wordsmith_utils/providers/order_provider.dart';
import 'package:wordsmith_utils/providers/user_library_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class EbookPurchaseWidget extends StatefulWidget {
  final Ebook ebook;
  final Function(UserLibrary entry) setLibraryEntry;

  const EbookPurchaseWidget({
    super.key,
    required this.ebook,
    required this.setLibraryEntry,
  });

  @override
  State<EbookPurchaseWidget> createState() => _EbookPurchaseWidgetState();
}

class _EbookPurchaseWidgetState extends State<EbookPurchaseWidget> {
  final _logger = LogManager.getLogger("EbookPurchaseWidget");
  late OrderProvider _orderProvider;
  late UserLibraryProvider _userLibraryProvider;
  late Future<Result<EntityResult<Order>>> _orderFuture;

  late Order _createdOrder;

  final double _imageAspectRatio = 1.5;
  final String _paypalBaseUrl = "https://www.sandbox.paypal.com/";

  void _capturePaymentForOrder() async {
    ProgressIndicatorDialog().show(context, text: "Processing...");
    await _orderProvider.capturePayment(_createdOrder.id).then((result) {
      switch (result) {
        case Success():
          _createdOrder = result.data.result!;
          _addToUserLibrary();
        case Failure(exception: final e):
          ProgressIndicatorDialog().dismiss();
          showSnackbar(context: context, content: e.toString());
      }
    });
  }

  void _addToUserLibrary() async {
    await _userLibraryProvider
        .addToUserLibrary(_createdOrder.eBookId!, _createdOrder.referenceId)
        .then((result) {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success<UserLibrary>():
          widget.setLibraryEntry(result.data);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (builder) => EbookPurchaseSuccessWidget(
              order: _createdOrder,
            ),
          ));
        case Failure<UserLibrary>(exception: final e):
          showSnackbar(context: context, content: e.toString());
      }
    });
  }

  WebViewController _createWebViewController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _logger.info("Loading $url..."),
          onPageFinished: (url) => _logger.info("Loaded $url"),
          onNavigationRequest: (request) {
            if (request.url.startsWith("https://example.com/returnUrl")) {
              _logger.info("Payment was a success!");
              Navigator.of(context).pop();
              _capturePaymentForOrder();
            }

            if (request.url.startsWith("https://example.com/cancelUrl")) {
              _logger.info("Payment was cancelled!");
              Navigator.of(context).pop();
            }

            if (!request.url.startsWith(_paypalBaseUrl)) {
              _logger.info("Blocking navigation to ${request.url}");
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_createdOrder.paymentUrl));
  }

  void _redirectToPayPal() async {
    final webviewController = _createWebViewController();

    Navigator.of(context).push(MaterialPageRoute(builder: (builder) {
      return Scaffold(
        body: WebViewWidget(
          controller: webviewController,
        ),
      );
    }));
  }

  void _confirmRedirection() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Note"),
            content: const Text(
              "You will be redirected to PayPal in order to finalize the purchase",
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  _redirectToPayPal();
                },
                child: const Text("Continue"),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    _orderProvider = context.read<OrderProvider>();
    _userLibraryProvider = context.read<UserLibraryProvider>();
    _orderFuture = _orderProvider.createOrder(widget.ebook.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Purchase ebook",
          style: theme.textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data;

          if (data == null || snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          switch (data) {
            case Success<EntityResult<Order>>():
              _createdOrder = data.data.result!;
            case Failure<EntityResult<Order>>(exception: final e):
              return Center(child: Text(e.toString()));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth * 0.35,
                        height: constraints.maxWidth * 0.35 * _imageAspectRatio,
                        child: EbookImageWidget(
                          coverArtUrl: widget.ebook.coverArt.imagePath!,
                          fit: BoxFit.fill,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(_createdOrder.eBookTitle),
                const SizedBox(height: 12.0),
                Text(
                  NumberFormatter.formatCurrency(_createdOrder.paymentAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  "Upon confirmation of purchase, your ebook will automatically be added to your library",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                const Divider(),
                const SizedBox(height: 32.0),
                ElevatedButton.icon(
                  onPressed: _confirmRedirection,
                  icon: const FaIcon(FontAwesomeIcons.paypal),
                  label: const Text("Pay with PayPal"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
