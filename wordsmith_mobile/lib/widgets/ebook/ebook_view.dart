import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/filters/ebook_filter_values.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';

class EbookViewWidget extends StatefulWidget {
  const EbookViewWidget({super.key});

  @override
  State<EbookViewWidget> createState() => _EbookViewWidgetState();
}

class _EbookViewWidgetState extends State<EbookViewWidget> {
  late EbookFilterValuesProvider _ebookFilterValuesProvider;

  Widget _buildHeader() {
    return const Text(
      "Sort by",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
      ),
    );
  }

  Widget _buildSortSelect() {
    var selectedSort = _ebookFilterValuesProvider.filterValues.sort;
    var selectedSortDirection =
        _ebookFilterValuesProvider.filterValues.sortDirection;

    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8.0,
          children: EbookSorts.values.map<ChoiceChip>(
            (sort) {
              return ChoiceChip(
                label: Text(sort.label),
                selected: selectedSort == sort,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _ebookFilterValuesProvider.updateFilterValueProperties(
                        sort: sort,
                        sortDirection: selectedSortDirection,
                      );
                    }
                  });
                },
              );
            },
          ).toList(),
        ),
        const Divider(),
        Wrap(
          spacing: 8.0,
          children: SortDirections.values.map<ChoiceChip>((direction) {
            return ChoiceChip(
              label: Text(direction.label),
              selected: selectedSortDirection == direction,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _ebookFilterValuesProvider.updateFilterValueProperties(
                      sort: selectedSort,
                      sortDirection: direction,
                    );
                  }
                });
              },
            );
          }).toList(),
        )
      ],
    );
  }

  @override
  void initState() {
    _ebookFilterValuesProvider = context.read<EbookFilterValuesProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Builder(builder: (context) => _buildHeader()),
          const Divider(height: 30.0),
          Builder(builder: (context) => _buildSortSelect()),
        ],
      ),
    );
  }
}
