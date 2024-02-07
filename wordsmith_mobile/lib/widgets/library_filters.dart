import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/utils/library_filter_values.dart';
import 'package:wordsmith_utils/logger.dart';

class LibraryFiltersWidget extends StatelessWidget {
  final LibraryFilterValues filterValues;
  final void Function(LibraryFilterValues values) onSelect;
  final _logger = LogManager.getLogger("LibraryFilters");

  LibraryFiltersWidget({
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
                  filterValues.clearFilters();
                  onSelect(filterValues);
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
                selected:
                    filterValues.isRead == null ? false : filterValues.isRead!,
                onSelected: (bool selected) {
                  filterValues.isRead = selected ? true : null;
                  onSelect(filterValues);
                },
              ),
              ChoiceChip(
                label: const Text("Unread"),
                selected:
                    filterValues.isRead == null ? false : !filterValues.isRead!,
                onSelected: (bool selected) {
                  filterValues.isRead = selected ? false : null;
                  onSelect(filterValues);
                },
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          const Text("Maturity rating"),
          Wrap(
            spacing: 8.0,
            children: List<Widget>.generate(filterValues.maturityRatings.length,
                (index) {
              return ChoiceChip(
                label: Text(filterValues.maturityRatings[index].name),
                selected: filterValues.selectedMaturityRating == index,
                onSelected: (bool selected) {
                  if (selected) {
                    filterValues.selectedMaturityRating = index;
                  } else {
                    filterValues.selectedMaturityRating = null;
                  }
                  onSelect(filterValues);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
