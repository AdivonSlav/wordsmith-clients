import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/ebook_screen.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_utils/datetime_formatter.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';

class LibraryInfoWidget extends StatefulWidget {
  final UserLibrary libraryEntry;

  const LibraryInfoWidget({super.key, required this.libraryEntry});

  @override
  State<LibraryInfoWidget> createState() => _LibraryInfoWidgetState();
}

class _LibraryInfoWidgetState extends State<LibraryInfoWidget> {
  final double imageAspectRatio = 1.5;

  void _openBookPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EBookScreenWidget(ebook: widget.libraryEntry.eBook),
      ),
    );
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
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text("Download"),
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
