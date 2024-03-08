import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_utils/logger.dart';

class ReaderScreenWidget extends StatefulWidget {
  final EbookIndexModel indexModel;

  const ReaderScreenWidget({super.key, required this.indexModel});

  @override
  State<ReaderScreenWidget> createState() => _ReaderScreenWidgetState();
}

class _ReaderScreenWidgetState extends State<ReaderScreenWidget> {
  final _logger = LogManager.getLogger("ReaderScreenWidget");
  final _selectedTextController = TextEditingController();
  late EpubController _epubController;

  void _openEpub() {
    var epubFile = File(widget.indexModel.path);
    _epubController = EpubController(document: EpubDocument.openFile(epubFile));
  }

  @override
  void initState() {
    super.initState();
    _openEpub();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.indexModel.title),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(
          controller: _epubController,
        ),
      ),
      body: EpubView(
        controller: _epubController,
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          chapterDividerBuilder: (_) => const Divider(),
          selectionAreaContextMenuBuilder: (context, selectableRegionState) {
            return AdaptiveTextSelectionToolbar.buttonItems(
              buttonItems: <ContextMenuButtonItem>[
                ContextMenuButtonItem(onPressed: () {}, label: "Define"),
              ],
              anchors: selectableRegionState.contextMenuAnchors,
            );
          },
        ),
      ),
    );
  }
}
