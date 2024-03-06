import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_utils/datetime_formatter.dart';

class LibraryOfflineInfoWidget extends StatefulWidget {
  final EbookIndexModel indexModel;

  const LibraryOfflineInfoWidget({super.key, required this.indexModel});

  @override
  State<LibraryOfflineInfoWidget> createState() =>
      _LibraryOfflineInfoWidgetState();
}

class _LibraryOfflineInfoWidgetState extends State<LibraryOfflineInfoWidget> {
  final double imageAspectRatio = 1.5;

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
                        Text(
                          "Read progress: ${widget.indexModel.readProgress}",
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
