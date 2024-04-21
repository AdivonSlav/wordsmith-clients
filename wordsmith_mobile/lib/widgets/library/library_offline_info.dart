import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/reader_screen.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/library/library_offline_remove.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';

class LibraryOfflineInfoWidget extends StatefulWidget {
  final EbookIndexModel indexModel;

  const LibraryOfflineInfoWidget({super.key, required this.indexModel});

  @override
  State<LibraryOfflineInfoWidget> createState() =>
      _LibraryOfflineInfoWidgetState();
}

class _LibraryOfflineInfoWidgetState extends State<LibraryOfflineInfoWidget> {
  final double imageAspectRatio = 1.5;

  Widget _buildInfoSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: constraints.maxWidth * 0.35,
              height: constraints.maxWidth * 0.35 * imageAspectRatio,
              child: EbookImageWidget(
                encodedCoverArt: widget.indexModel.encodedImage,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(width: 10.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.indexModel.title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "by ${widget.indexModel.author}",
                    style: const TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    "Added to library: ${formatDateTime(date: widget.indexModel.syncDate, format: "yMMMMd")}",
                    style: const TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FilledButton.icon(
          onPressed: () => _openReaderPage(),
          icon: const Icon(Icons.chrome_reader_mode),
          label: const Text("Read"),
        ),
        IconButton.filledTonal(
          onPressed: _showRemoveDialog,
          color: Colors.red,
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  void _showRemoveDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return LibraryOfflineRemoveWidget(indexModel: widget.indexModel);
        }).then(
      (result) {
        if (result == null) return;
        if (result == true) Navigator.of(context).pop(true);
      },
    );
  }

  void _openReaderPage() {
    var model = widget.indexModel;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReaderScreenWidget(indexModel: model),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(builder: (context) => _buildInfoSection()),
          const Divider(),
          Builder(builder: (context) => _buildActionSection()),
        ],
      ),
    );
  }
}
