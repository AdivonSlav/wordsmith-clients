import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/ebook_comments_screen.dart';
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

  final bool _showAppBar = true;

  void _openEpub() async {
    var epubFile = File(widget.indexModel.path);
    _epubController = EpubController(document: EpubDocument.openFile(epubFile));
  }

  void _openEbookComments() async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EbookCommentsScreenWidget(
        ebookId: widget.indexModel.id,
        isInLibrary: true,
      ),
    ));
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_showAppBar) {
      return AppBar(
        title: Text(
          widget.indexModel.title,
          style: const TextStyle(fontSize: 18.0),
        ),
        // title: EpubViewActualChapter(
        //   controller: _epubController,
        //   builder: (chapterValue) {
        //     return Text(
        //       chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
        //       textAlign: TextAlign.start,
        //     );
        //   },
        // ),
        actions: const <Widget>[
          BackButton(),
        ],
      );
    }

    return null;
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(widget.indexModel.title),
          ),
          ListTile(
            title: const Text("Comments"),
            leading: const Icon(Icons.comment),
            onTap: () => _openEbookComments(),
          ),
          ExpansionTile(
            title: const Text("Chapters"),
            leading: const Icon(Icons.layers),
            children: [
              EpubViewTableOfContents(
                padding: EdgeInsets.zero,
                controller: _epubController,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index, chapter, itemCount) {
                  return ListTile(
                    title: Text(
                      chapter.title!.trim(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    onTap: () =>
                        _epubController.scrollTo(index: chapter.startIndex),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
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
      drawer: _buildDrawer(),
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
