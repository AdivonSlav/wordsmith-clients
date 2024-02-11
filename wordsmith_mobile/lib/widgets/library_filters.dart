import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/library_filter_values.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/maturity_rating/maturity_rating.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/providers/maturity_ratings_provider.dart';

class LibraryFiltersWidget extends StatefulWidget {
  final LibraryFilterValues filterValues;
  final void Function(LibraryFilterValues values) onSelect;

  const LibraryFiltersWidget({
    super.key,
    required this.filterValues,
    required this.onSelect,
  });

  @override
  State<LibraryFiltersWidget> createState() => _LibraryFiltersWidgetState();
}

class _LibraryFiltersWidgetState extends State<LibraryFiltersWidget> {
  final _logger = LogManager.getLogger("LibraryFilters");
  late MaturityRatingsProvider _maturityRatingsProvider;
  late Future<QueryResult<MaturityRating>> _maturityRatingsFuture;

  Future<QueryResult<MaturityRating>> _getMaturityRatings() async {
    try {
      return await _maturityRatingsProvider.getMaturityRatings();
    } on Exception catch (error) {
      _logger.severe(error);
      return Future.error(error);
    }
  }

  @override
  void initState() {
    _maturityRatingsProvider = context.read<MaturityRatingsProvider>();
    _maturityRatingsFuture = _getMaturityRatings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: FutureBuilder(
        future: _maturityRatingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          var maturityRatings = snapshot.data!.result;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filters",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.filterValues.clearFilters();
                      widget.onSelect(widget.filterValues);
                    },
                    child: const Text("Clear all"),
                  ),
                ],
              ),
              const Divider(
                height: 30.0,
              ),
              const Text("Status"),
              Wrap(
                spacing: 8.0,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text("Read"),
                    selected: widget.filterValues.isRead == null
                        ? false
                        : widget.filterValues.isRead!,
                    onSelected: (bool selected) {
                      widget.filterValues.isRead = selected ? true : null;
                      widget.onSelect(widget.filterValues);
                    },
                  ),
                  ChoiceChip(
                    label: const Text("Unread"),
                    selected: widget.filterValues.isRead == null
                        ? false
                        : !widget.filterValues.isRead!,
                    onSelected: (bool selected) {
                      widget.filterValues.isRead = selected ? false : null;
                      widget.onSelect(widget.filterValues);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              const Text("Maturity rating"),
              Wrap(
                spacing: 8.0,
                children:
                    List<Widget>.generate(maturityRatings.length, (index) {
                  var rating = maturityRatings[index];

                  return ChoiceChip(
                    label: Text(rating.name),
                    selected: widget.filterValues.selectedMaturityRatingId ==
                        rating.id,
                    onSelected: (bool selected) {
                      if (selected) {
                        widget.filterValues.selectedMaturityRatingId =
                            rating.id;
                      } else {
                        widget.filterValues.selectedMaturityRatingId = null;
                      }
                      widget.onSelect(widget.filterValues);
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
