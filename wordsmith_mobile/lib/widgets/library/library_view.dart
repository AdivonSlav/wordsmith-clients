import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/utils/filters/library_filter_values.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';

class LibraryViewWidget extends StatelessWidget {
  final LibraryFilterValues filterValues;
  final void Function(LibraryFilterValues values) onSelect;

  const LibraryViewWidget({
    super.key,
    required this.filterValues,
    required this.onSelect,
  });

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
                selected: filterValues.sort == sort,
                onSelected: (bool selected) {
                  if (selected) {
                    filterValues.sort = sort;
                    onSelect(filterValues);
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
                selected:
                    filterValues.sortDirection == SortDirections.ascending,
                onSelected: (bool selected) {
                  if (selected) {
                    filterValues.sortDirection = SortDirections.ascending;
                    onSelect(filterValues);
                  }
                },
              ),
              ChoiceChip(
                label: Text(SortDirections.descending.label),
                selected:
                    filterValues.sortDirection == SortDirections.descending,
                onSelected: (bool selected) {
                  if (selected) {
                    filterValues.sortDirection = SortDirections.descending;
                    onSelect(filterValues);
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
