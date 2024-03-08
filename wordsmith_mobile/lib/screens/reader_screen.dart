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

  bool _showAppBar = true;

  void _openEpub() async {
    var epubFile = File(widget.indexModel.path);
    _epubController = EpubController(document: EpubDocument.openFile(epubFile));
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_showAppBar) {
      return AppBar(
        title: EpubViewActualChapter(
          controller: _epubController,
          builder: (chapterValue) {
            return Text(
              chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
              textAlign: TextAlign.start,
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      );
    }

    return null;
  }

  @override
  void initState() {
    _openEpub();
    super.initState();
  }

  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: Drawer(
        child: EpubViewTableOfContents(
          controller: _epubController,
        ),
      ),
      body: EpubView(
        controller: _epubController,
        onDocumentLoaded: (document) =>
            _logger.info("Loaded ${document.Title} for reading"),
        onSelectedContentChanged: (content) {},
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
