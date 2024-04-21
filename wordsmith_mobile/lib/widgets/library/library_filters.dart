import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/filters/library_filter_values.dart';
import 'package:wordsmith_utils/models/maturity_rating/maturity_rating.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/maturity_ratings_provider.dart';

class LibraryFiltersWidget extends StatefulWidget {
  const LibraryFiltersWidget({super.key});

  @override
  State<LibraryFiltersWidget> createState() => _LibraryFiltersWidgetState();
}

class _LibraryFiltersWidgetState extends State<LibraryFiltersWidget> {
  late LibraryFilterValuesProvider _filterValuesProvider;

  late Future<Result<QueryResult<MaturityRating>>> _getMaturityRatings;

  @override
  void initState() {
    _filterValuesProvider = context.read<LibraryFilterValuesProvider>();
    _getMaturityRatings =
        context.read<MaturityRatingsProvider>().getMaturityRatings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: FutureBuilder(
        future: _getMaturityRatings,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          List<MaturityRating> maturityRatings = [];

          switch (snapshot.data!) {
            case Success(data: final d):
              maturityRatings = d.result;
            case Failure(exception: final e):
              return Center(child: Text(e.toString()));
          }

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
                      _filterValuesProvider.clearFilterValues();
                      Navigator.of(context).pop();
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
                    selected: _filterValuesProvider.filterValues.isRead == null
                        ? false
                        : _filterValuesProvider.filterValues.isRead!,
                    onSelected: (bool selected) {
                      _filterValuesProvider.updateFilterValueProperties(
                        isRead: selected ? true : null,
                        selectedCategory:
                            _filterValuesProvider.filterValues.selectedCategory,
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                  ChoiceChip(
                    label: const Text("Unread"),
                    selected: _filterValuesProvider.filterValues.isRead == null
                        ? false
                        : !_filterValuesProvider.filterValues.isRead!,
                    onSelected: (bool selected) {
                      _filterValuesProvider.updateFilterValueProperties(
                        isRead: selected ? false : null,
                        selectedCategory:
                            _filterValuesProvider.filterValues.selectedCategory,
                      );
                      Navigator.of(context).pop();
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
                    selected: _filterValuesProvider
                            .filterValues.selectedMaturityRatingId ==
                        rating.id,
                    onSelected: (bool selected) {
                      if (selected) {
                        _filterValuesProvider.updateFilterValueProperties(
                            selectedMaturityRatingId: rating.id);
                      } else {
                        _filterValuesProvider.updateFilterValueProperties(
                            selectedMaturityRatingId: null);
                      }
                      Navigator.of(context).pop();
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
