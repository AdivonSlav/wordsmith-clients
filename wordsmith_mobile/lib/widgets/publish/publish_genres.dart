import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/multiselect_dialog.dart';
import 'package:wordsmith_utils/models/genre/genre.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/genre_provider.dart';

class PublishGenresWidget extends StatefulWidget {
  final void Function(List<Genre> genres) onGenreSelect;

  const PublishGenresWidget({
    super.key,
    required this.onGenreSelect,
  });

  @override
  State<StatefulWidget> createState() => _PublishGenresWidgetState();
}

class _PublishGenresWidgetState extends State<PublishGenresWidget> {
  List<Genre> _genres = [];
  List<String> _items = [];
  List<String> _selectedItems = [];

  late Future<Result<QueryResult<Genre>>> _getGenres;

  List<String> _parseGenreNames(List<Genre> genres) {
    return genres.map((e) => e.name).toList();
  }

  Future<List<String>?> _openGenresDialog() async {
    final List<String>? results = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialogWidget(
            title: "Select genres",
            items: _items,
            selectedItems: _selectedItems,
          );
        });

    return results;
  }

  @override
  void initState() {
    super.initState();
    _getGenres = context.read<GenreProvider>().getGenres();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            "Choose a genre",
            style: theme.textTheme.labelLarge,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 5.0),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: FutureBuilder(
                    future: _getGenres,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const CircularProgressIndicator();
                      }

                      switch (snapshot.data!) {
                        case Success(data: final d):
                          _genres = d.result;
                          _items = _parseGenreNames(d.result);
                        case Failure(exception: final e):
                          return Center(child: Text(e.toString()));
                      }
                      // snapshot.data will never be null here.

                      return Column(
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              var results = await _openGenresDialog();

                              if (results != null) {
                                setState(() {
                                  _selectedItems = results;
                                  var selectedGenreObjects = _genres
                                      .where((e) =>
                                          _selectedItems.contains(e.name))
                                      .toList();
                                  widget.onGenreSelect(selectedGenreObjects);
                                });
                              }
                            },
                            child: const Text("Select genres"),
                          ),
                          const Divider(
                            height: 30.0,
                          ),
                          Wrap(
                            spacing: 6.0,
                            children: _selectedItems
                                .map((e) => Chip(label: Text(e)))
                                .toList(),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
