import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/utils/library_filter_values.dart';

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
                label: Text(LibrarySortDirections.ascending.label),
                selected: filterValues.sortDirection ==
                    LibrarySortDirections.ascending,
                onSelected: (bool selected) {
                  if (selected) {
                    filterValues.sortDirection =
                        LibrarySortDirections.ascending;
                    onSelect(filterValues);
                  }
                },
              ),
              ChoiceChip(
                label: Text(LibrarySortDirections.descending.label),
                selected: filterValues.sortDirection ==
                    LibrarySortDirections.descending,
                onSelected: (bool selected) {
                  if (selected) {
                    filterValues.sortDirection =
                        LibrarySortDirections.descending;
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
