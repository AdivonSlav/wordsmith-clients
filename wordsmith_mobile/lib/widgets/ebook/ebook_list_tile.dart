import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/ebook_screen.dart';
import 'package:wordsmith_mobile/screens/profile_screen.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';

class EbookListTile extends StatefulWidget {
  final Ebook ebook;
  final bool displayAuthor;

  const EbookListTile({
    super.key,
    required this.ebook,
    this.displayAuthor = true,
  });

  @override
  State<EbookListTile> createState() => _EbookListTileState();
}

class _EbookListTileState extends State<EbookListTile> {
  Widget _buildEbookCover(BoxConstraints constraints) {
    double coverHeight = constraints.maxHeight;
    double coverWidth = coverHeight * (1 / 1.6); //  1:1.6 aspect ratio

    return EbookImageWidget(
      coverArtUrl: widget.ebook.coverArt.imagePath,
      width: coverWidth,
      height: coverHeight,
      fit: BoxFit.fill,
      addShadow: false,
    );
  }

  Widget _buildEbookInfo(BoxConstraints constraints) {
    var ebook = widget.ebook;
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ebook.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16.0),
          ),
          if (widget.displayAuthor)
            Text.rich(
              TextSpan(
                  text: "by ",
                  children: [
                    TextSpan(
                      text: ebook.author.username,
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _openUserProfileScreen(),
                    ),
                  ],
                  style: const TextStyle(fontSize: 13.0)),
            ),
          const Spacer(),
          Text(
            ebook.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.0),
          ),
          const Spacer(),
          Text(
            "Rated: ${ebook.maturityRating.shortName}",
            style: const TextStyle(
              fontSize: 10.0,
              color: Colors.grey,
            ),
          ),
          Text(
            "Published: ${formatDateTime(date: ebook.publishedDate, format: "yMMMd")}",
            style: const TextStyle(
              fontSize: 10.0,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  void _openEbookScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EbookScreenWidget(ebookId: widget.ebook.id),
      ),
    );
  }

  void _openUserProfileScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProfileScreenWidget(userId: widget.ebook.author.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openEbookScreen(),
        child: SizedBox(
          width: double.infinity,
          height: 180.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Builder(
                        builder: (context) => _buildEbookCover(constraints)),
                    const SizedBox(width: 12.0),
                    Builder(builder: (context) => _buildEbookInfo(constraints)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
