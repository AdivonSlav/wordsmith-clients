import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/screens/ebook_screen.dart';
import 'package:wordsmith_mobile/utils/ebook_indexer.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_utils/datetime_formatter.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_info_dialog.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook_parse.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
import 'package:wordsmith_utils/providers/ebook_download_provider.dart';
import 'package:wordsmith_utils/providers/ebook_parse_provider.dart';

class LibraryInfoWidget extends StatefulWidget {
  final UserLibrary libraryEntry;

  const LibraryInfoWidget({super.key, required this.libraryEntry});

  @override
  State<LibraryInfoWidget> createState() => _LibraryInfoWidgetState();
}

class _LibraryInfoWidgetState extends State<LibraryInfoWidget> {
  final _logger = LogManager.getLogger("LibraryInfoWidget");
  late EBookDownloadProvider _eBookDownloadProvider;
  late EBookParseProvider _eBookParseProvider;

  final double imageAspectRatio = 1.5;

  EBookIndexModel? _indexModel;

  void _openBookPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EBookScreenWidget(ebook: widget.libraryEntry.eBook),
      ),
    );
  }

  Future<TransferFile?> _downloadBook() async {
    ProgressIndicatorDialog().show(context, text: "Downloading...");
    return await _eBookDownloadProvider
        .download(widget.libraryEntry.eBookId)
        .then((result) {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success<TransferFile>(data: final d):
          _logger.info("Downloaded ${d.name}");
          return d;
        case Failure<TransferFile>(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }

      return null;
    });
  }

  Future<String?> _parseForCoverArt(TransferFile file) async {
    ProgressIndicatorDialog().show(context, text: "Parsing...");
    return await _eBookParseProvider.getParsed(file).then((result) {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success<EBookParse>(data: final d):
          _logger.info("Got parsed cover art for ${file.name}");
          return d.encodedCoverArt;
        case Failure<EBookParse>(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }

      return null;
    });
  }

  Future<EBookIndexModel?> _index(TransferFile file) async {
    ProgressIndicatorDialog().show(context, text: "Indexing...");
    return await EBookIndexer.addToIndex(widget.libraryEntry, file)
        .then((result) {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success(data: final d):
          _logger.info("Added to index with path ${d.path}");
          return d;
        case Failure(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }

      return null;
    });
  }

  Future<void> _syncToLibrary() async {
    if (_indexModel != null) return;

    TransferFile? file = await _downloadBook();

    if (file == null) return;

    String? encodedCoverArt = await _parseForCoverArt(file);
    widget.libraryEntry.eBook.coverArt.encodedImage = encodedCoverArt;

    if (encodedCoverArt == null) return;

    await _index(file).then((result) async {
      if (result != null) {
        await showInfoDialog(
          context: context,
          title: const Text("Success"),
          content: const Text(
            "Succesfully downloaded the ebook!",
          ),
        );

        setState(() {
          _indexModel = result;
        });
      }
    });
  }

  Future<void> _fetchIndexEntry() async {
    await EBookIndexer.getById(widget.libraryEntry.eBookId).then((result) {
      switch (result) {
        case Success<EBookIndexModel?>():
          setState(() {
            _indexModel = result.data;
          });
        case Failure<EBookIndexModel?>():
          showErrorDialog(context: context, content: Text(result.toString()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _eBookDownloadProvider = context.read<EBookDownloadProvider>();
    _eBookParseProvider = context.read<EBookParseProvider>();
    // _indexModelFuture = EBookIndexer.getById(widget.libraryEntry.eBookId);
    _fetchIndexEntry();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: constraints.maxWidth * 0.35,
                    height: constraints.maxWidth * 0.35 * imageAspectRatio,
                    child: EBookImageWidget(
                      coverArtUrl:
                          widget.libraryEntry.eBook.coverArt.imagePath!,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.libraryEntry.eBook.title,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "by ${widget.libraryEntry.eBook.author.username}",
                          style: const TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Text(
                          "Added to library: ${formatDateTime(date: widget.libraryEntry.syncDate, format: "yMMMMd")}",
                          style: const TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                        Text(
                          "Read progress: ${widget.libraryEntry.readProgress}",
                          style: const TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(height: 34.0),
                        IconButton.outlined(
                          onPressed: _openBookPage,
                          icon: const Icon(Icons.open_in_new),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chrome_reader_mode),
                label: const Text("Read"),
              ),
              FilledButton.icon(
                onPressed: _syncToLibrary,
                icon: Icon(
                    _indexModel == null ? Icons.download : Icons.download_done),
                label: Text(_indexModel == null ? "Download" : "Downloaded"),
              ),
              IconButton.filledTonal(
                onPressed: () {},
                color: Colors.red,
                icon: const Icon(Icons.delete),
              ),
            ],
          )
        ],
      ),
    );
  }
}
