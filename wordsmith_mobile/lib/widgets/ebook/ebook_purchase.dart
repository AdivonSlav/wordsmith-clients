import 'package:flutter/material.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';

class EbookPurchaseWidget extends StatefulWidget {
  final Ebook ebook;

  const EbookPurchaseWidget({super.key, required this.ebook});

  @override
  State<EbookPurchaseWidget> createState() => _EbookPurchaseWidgetState();
}

class _EbookPurchaseWidgetState extends State<EbookPurchaseWidget> {
  final _logger = LogManager.getLogger("EbookPurchaseWidget");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
