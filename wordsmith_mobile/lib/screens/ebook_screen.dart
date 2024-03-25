import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/screens/ebook_comments_screen.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_purchase.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_rating_display.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_rating_minimal_display.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/formatters/number_formatter.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';
import 'package:wordsmith_utils/providers/user_library_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class EbookScreenWidget extends StatefulWidget {
  final int ebookId;

  const EbookScreenWidget({super.key, required this.ebookId});

  @override
  State<StatefulWidget> createState() => _EbookScreenWidget();
}

class _EbookScreenWidget extends State<EbookScreenWidget> {
  late UserLibraryProvider _userLibraryProvider;
  late EbookProvider _ebookProvider;

  late Future<Result<QueryResult<Ebook>>> _ebookFuture;
  UserLibrary? _userLibrary;

  String _formatPrice(double? price) {
    if (price == null) {
      return "Free";
    }

    return NumberFormatter.formatCurrency(price);
  }

  void _showRatingDialog(Ebook ebook) async {
    await showDialog(
      context: context,
      builder: (context) => EbookRatingDisplayWidget(
        ebook: ebook,
        isInLibrary: _userLibrary != null,
      ),
    );
  }

  void _showCommentsScreen(Ebook ebook) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EbookCommentsScreenWidget(
          ebook: ebook, isInLibrary: _userLibrary != null),
    ));
  }

  void _showAddToLibraryDialog(Ebook ebook) async {
    if (_userLibrary != null) {
      return;
    }

    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          if (ebook.price != null) {
            return EbookPurchaseWidget(
              ebook: ebook,
              setLibraryEntry: _setLibraryEntry,
            );
          }

          return AlertDialog(
            title: const Text("Add to library"),
            content:
                const Text("Do you want to add this book to your library?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Add"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
            ],
          );
        });

    if (result == true) {
      _addToLibrary();
    }
  }

  void _addToLibrary() async {
    ProgressIndicatorDialog().show(context);

    await _userLibraryProvider.addToUserLibrary(widget.ebookId).then((result) {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success<UserLibrary>():
          _setLibraryEntry(result.data);
        case Failure<UserLibrary>():
          showSnackbar(context: context, content: result.exception.toString());
      }
    });
  }

  void _getLibraryEntry() async {
    await _userLibraryProvider
        .getLibraryEntryByEbook(eBookId: widget.ebookId)
        .then((result) {
      switch (result) {
        case Success():
          if (result.data != null) {
            _setLibraryEntry(result.data!);
          }
        case Failure(exception: final e):
          showSnackbar(context: context, content: e.toString());
      }
    });
  }

  void _setLibraryEntry(UserLibrary entry) {
    setState(() {
      _userLibrary = entry;
    });
  }

  @override
  void initState() {
    super.initState();
    _userLibraryProvider = context.read<UserLibraryProvider>();
    _ebookProvider = context.read<EbookProvider>();

    _ebookFuture = _ebookProvider.getById(widget.ebookId);
    _getLibraryEntry();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder(
        future: _ebookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          var result = snapshot.data;

          if (snapshot.hasError || result == null) {
            return Center(
              child: Text(snapshot.error?.toString() ?? "Failed to load ebook"),
            );
          }

          late Ebook ebook;

          switch (result) {
            case Success<QueryResult<Ebook>>(data: final d):
              if (d.result.isNotEmpty) {
                ebook = d.result.first;
              } else {
                return const Center(
                  child: Text("Could not find the specified ebook!"),
                );
              }
            case Failure<QueryResult<Ebook>>(exception: final e):
              return Center(
                child: Text(e.toString()),
              );
          }

          return Stack(
            children: <Widget>[
              Hero(
                tag: ebook.title,
                child: EbookImageWidget(
                  width: size.width,
                  height: size.height * 0.75,
                  coverArtUrl: ebook.coverArt.imagePath,
                  fit: BoxFit.fitWidth,
                  imageAlignment: Alignment.topCenter,
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
                                padding: const EdgeInsets.only(right: 12.0),
                                child: IconButton(
                                  icon: _userLibrary == null
                                      ? const Icon(Icons.add_circle_outline)
                                      : const Icon(Icons.check_circle),
                                  onPressed: () =>
                                      _showAddToLibraryDialog(ebook),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.favorite_outline),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: IconButton(
                                  onPressed: () => _showRatingDialog(ebook),
                                  icon: const Icon(Icons.thumb_up),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: IconButton(
                                  onPressed: () => _showCommentsScreen(ebook),
                                  icon: const Icon(Icons.comment),
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
                                  ebook.title,
                                  style: TextStyle(
                                    fontSize: theme
                                        .textTheme.headlineMedium!.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: "by ",
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: theme
                                              .textTheme.labelMedium!.color),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ebook.author.username,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: theme.textTheme
                                                    .labelMedium!.color,
                                                decoration:
                                                    TextDecoration.underline))
                                      ]),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: EbookRatingMinimalDisplayWidget(
                                      rating: ebook.ratingAverage),
                                ),
                                Text(
                                  _formatPrice(ebook.price),
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
                                        child: Text(ebook.maturityRating.name),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  ebook.genres
                                      .replaceFirst(RegExp(r";$"), "")
                                      .split(";")
                                      .join(", "),
                                  textAlign: TextAlign.start,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                                date: ebook.publishedDate,
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
                                              date: ebook.updatedDate,
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
                                          ebook.chapterCount.toString(),
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
                                  ebook.description,
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
          );
        },
      ),
    );
  }
}
