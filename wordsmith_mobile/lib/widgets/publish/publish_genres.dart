import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/multiselect_dialog.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/genre/genre.dart';
import 'package:wordsmith_utils/models/query_result.dart';
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
  final _logger = LogManager.getLogger("PublishGenresWidget");
  List<String> _items = [];
  List<String> _selectedItems = [];

  late GenreProvider _genreProvider;
  late Future<QueryResult<Genre>> _getGenresFuture;

  Future<QueryResult<Genre>> _loadGenres() async {
    try {
      var result = await _genreProvider.getGenres();

      return result;
    } on BaseException catch (error) {
      _logger.info(error);
      return Future.error(error);
    } on Exception catch (error) {
      _logger.severe(error);
      return Future.error(error);
    }
  }

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
    _genreProvider = context.read<GenreProvider>();
    _getGenresFuture = _loadGenres();
    super.initState();
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
                    future: _getGenresFuture,
                    builder:
                        (context, AsyncSnapshot<QueryResult<Genre>> snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError || snapshot.data == null) {
                        return Text(snapshot.error.toString());
                      }

                      // snapshot.data will never be null here.
                      _items = _parseGenreNames(snapshot.data!.result);

                      return Column(
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              var results = await _openGenresDialog();

                              if (results != null) {
                                setState(() {
                                  _selectedItems = results;
                                  var selectedGenreObjects = snapshot
                                      .data!.result
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
