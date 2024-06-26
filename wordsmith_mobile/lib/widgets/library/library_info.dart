import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/screens/ebook_screen.dart';
import 'package:wordsmith_mobile/screens/profile_screen.dart';
import 'package:wordsmith_mobile/screens/reader_screen.dart';
import 'package:wordsmith_mobile/utils/indexers/ebook_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/library/library_remove.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_info_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
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
  late EbookDownloadProvider _eBookDownloadProvider;
  late EbookParseProvider _eBookParseProvider;
  late EbookIndexProvider _ebookIndexProvider;

  final double imageAspectRatio = 1.5;

  EbookIndexModel? _indexModel;

  Widget _buildEbookInfo() {
    var size = MediaQuery.of(context).size;
    return Flexible(
      child: SizedBox(
        height: size.height * 0.25,
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
            RichText(
              text: TextSpan(text: "by ", children: <TextSpan>[
                TextSpan(
                  text: widget.libraryEntry.eBook.author.username,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showAuthorProfileScreen(),
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                )
              ]),
            ),
            const Spacer(),
            Text(
              "Added to library: ${formatDateTime(date: widget.libraryEntry.syncDate, format: "yMMMMd")}",
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
            const Spacer(),
            IconButton.outlined(
              onPressed: _openBookPage,
              icon: const Icon(Icons.open_in_new),
            )
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return LibraryRemoveWidget(
              indexModel: _indexModel, libraryEntry: widget.libraryEntry);
        }).then(
      (result) {
        if (result == null) return;
        if (result == true) Navigator.of(context).pop(true);
      },
    );
  }

  void _showAuthorProfileScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ProfileScreenWidget(userId: widget.libraryEntry.eBook.author.id)));
  }

  void _openReaderPage() async {
    if (_indexModel == null) {
      await _syncToLibrary(showSuccessDialog: false).then((value) {
        var model = _indexModel;

        if (model == null) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReaderScreenWidget(indexModel: model),
          ),
        );
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReaderScreenWidget(indexModel: _indexModel!),
        ),
      );
    }
  }

  void _openBookPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EbookScreenWidget(ebookId: widget.libraryEntry.eBook.id),
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
        case Success<EbookParse>(data: final d):
          _logger.info("Got parsed cover art for ${file.name}");
          return d.encodedCoverArt;
        case Failure<EbookParse>(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }

      return null;
    });
  }

  Future<EbookIndexModel?> _index(TransferFile file) async {
    ProgressIndicatorDialog().show(context, text: "Indexing...");
    return await _ebookIndexProvider
        .addToIndex(widget.libraryEntry, file)
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

  Future<void> _syncToLibrary({bool showSuccessDialog = true}) async {
    if (_indexModel != null) return;

    TransferFile? file = await _downloadBook();

    if (file == null) return;

    String? encodedCoverArt = await _parseForCoverArt(file);
    widget.libraryEntry.eBook.coverArt.encodedImage = encodedCoverArt;

    if (encodedCoverArt == null) return;

    await _index(file).then((result) async {
      if (result != null) {
        if (showSuccessDialog) {
          await showInfoDialog(
            context: context,
            title: const Text("Success"),
            content: const Text(
              "Succesfully downloaded the ebook!",
            ),
          );
        }

        setState(() {
          _indexModel = result;
        });
      }
    });
  }

  Future<void> _fetchIndexEntry() async {
    await _ebookIndexProvider
        .getById(widget.libraryEntry.eBookId)
        .then((result) {
      switch (result) {
        case Success<EbookIndexModel?>():
          setState(() {
            _indexModel = result.data;
          });
        case Failure<EbookIndexModel?>():
          showErrorDialog(context: context, content: Text(result.toString()));
      }
    });
  }

  @override
  void initState() {
    _eBookDownloadProvider = context.read<EbookDownloadProvider>();
    _eBookParseProvider = context.read<EbookParseProvider>();
    _ebookIndexProvider = context.read<EbookIndexProvider>();

    Future.microtask(() {
      _fetchIndexEntry();
    });

    super.initState();
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
                    child: EbookImageWidget(
                      coverArtUrl:
                          widget.libraryEntry.eBook.coverArt.imagePath!,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Builder(builder: (context) => _buildEbookInfo()),
                ],
              );
            },
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _openReaderPage,
                icon: const Icon(Icons.chrome_reader_mode),
                label: const Text("Read"),
              ),
              FilledButton.icon(
                onPressed: _indexModel == null ? _syncToLibrary : null,
                icon: Icon(
                    _indexModel == null ? Icons.download : Icons.download_done),
                label: Text(_indexModel == null ? "Download" : "Downloaded"),
              ),
              IconButton.filledTonal(
                onPressed: _showRemoveDialog,
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
