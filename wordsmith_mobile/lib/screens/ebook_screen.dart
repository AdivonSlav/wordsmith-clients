import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/ebook_rating_stars.dart';
import 'package:wordsmith_utils/datetime_formatter.dart';
import 'package:wordsmith_utils/models/ebook.dart';

class EBookScreenWidget extends StatefulWidget {
  final EBook ebook;

  const EBookScreenWidget({super.key, required this.ebook});

  @override
  State<StatefulWidget> createState() => _EBookScreenWidget();
}

class _EBookScreenWidget extends State<EBookScreenWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Hero(
            tag: widget.ebook.title,
            child: EBookImageWidget(
              coverArtUrl: widget.ebook.coverArt.imagePath,
              maxWidth: size.width,
              fit: BoxFit.fitWidth,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 48.0, left: 32.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 42.0,
                height: 42.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.35,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                height: size.height * 0.6,
                padding: const EdgeInsets.only(top: 10.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.download),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite_outline),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            right: 32.0, left: 32.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              widget.ebook.title,
                              style: TextStyle(
                                fontSize:
                                    theme.textTheme.headlineMedium!.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                  text: "by ",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color:
                                          theme.textTheme.labelMedium!.color),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: widget.ebook.author.username,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: theme
                                                .textTheme.labelMedium!.color,
                                            decoration:
                                                TextDecoration.underline))
                                  ]),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: <Widget>[
                                  EBookRatingStarsWidget(
                                      rating: widget.ebook.ratingAverage),
                                  const SizedBox(width: 12.0),
                                  Text(
                                    "${widget.ebook.ratingAverage ?? "0.0"} (0 ratings)",
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${widget.ebook.price ?? "Free"}",
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child:
                                        Text(widget.ebook.maturityRating.name),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              widget.ebook.genres
                                  .replaceFirst(RegExp(r";$"), "")
                                  .split(";")
                                  .join(", "),
                              textAlign: TextAlign.start,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      const Text(
                                        "Published",
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                        formatDateTime(
                                            date: widget.ebook.publishedDate,
                                            format: "yMMMd"),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    const Text(
                                      "Updated",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    Text(
                                      formatDateTime(
                                          date: widget.ebook.updatedDate,
                                          format: "yMMMd"),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    const Text(
                                      "Chapter count",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    Text(
                                      widget.ebook.chapterCount.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              widget.ebook.description,
                              style: theme.textTheme.bodyMedium,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
