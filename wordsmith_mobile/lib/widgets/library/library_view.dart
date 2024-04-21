import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/filters/library_filter_values.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';

class LibraryViewWidget extends StatefulWidget {
  const LibraryViewWidget({super.key});

  @override
  State<LibraryViewWidget> createState() => _LibraryViewWidgetState();
}

class _LibraryViewWidgetState extends State<LibraryViewWidget> {
  late LibraryFilterValuesProvider _filterValuesProvider;

  @override
  void initState() {
    _filterValuesProvider = context.read<LibraryFilterValuesProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            "Sort by",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
            ),
          ),
          const Divider(height: 30.0),
          Wrap(
            spacing: 8.0,
            children: LibrarySorts.values.map<ChoiceChip>((sort) {
              return ChoiceChip(
                label: Text(sort.label),
                selected: _filterValuesProvider.filterValues.sort == sort,
                onSelected: (bool selected) {
                  if (selected) {
                    _filterValuesProvider.updateFilterValueProperties(
                      sort: sort,
                      selectedCategory:
                          _filterValuesProvider.filterValues.selectedCategory,
                    );
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
          const Divider(),
          Wrap(
            spacing: 8.0,
            children: <Widget>[
              ChoiceChip(
                label: Text(SortDirections.ascending.label),
                selected: _filterValuesProvider.filterValues.sortDirection ==
                    SortDirections.ascending,
                onSelected: (bool selected) {
                  if (selected) {
                    _filterValuesProvider.updateFilterValueProperties(
                      sortDirection: SortDirections.ascending,
                      selectedCategory:
                          _filterValuesProvider.filterValues.selectedCategory,
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
              ChoiceChip(
                label: Text(SortDirections.descending.label),
                selected: _filterValuesProvider.filterValues.sortDirection ==
                    SortDirections.descending,
                onSelected: (bool selected) {
                  if (selected) {
                    _filterValuesProvider.updateFilterValueProperties(
                      sortDirection: SortDirections.descending,
                      selectedCategory:
                          _filterValuesProvider.filterValues.selectedCategory,
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
