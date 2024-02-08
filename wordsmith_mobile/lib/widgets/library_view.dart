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
    var sortByList = {
      "SyncDate": "Most recent",
      "EBook.PublishedDate": "Publication date",
      "EBook.Title": "Title",
    };

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
            children: sortByList.entries.map<ChoiceChip>((entry) {
              var property = entry.key;
              var label = entry.value;
              return ChoiceChip(
                label: Text(label),
                selected: filterValues.sortByProperty == property,
                onSelected: (bool selected) {
                  if (selected) {
                    filterValues.sortByProperty = property;
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
                label: const Text("Ascending"),
                selected: filterValues.sortByDirection == "asc",
                onSelected: (bool selected) {
                  if (selected) {
                    filterValues.sortByDirection = "asc";
                    onSelect(filterValues);
                  }
                },
              ),
              ChoiceChip(
                label: const Text("Descending"),
                selected: filterValues.sortByDirection == "desc",
                onSelected: (bool selected) {
                  if (selected) {
                    filterValues.sortByDirection = "desc";
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
