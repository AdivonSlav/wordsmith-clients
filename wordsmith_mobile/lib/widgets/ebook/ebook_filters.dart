import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/filters/ebook_filter_values.dart';
import 'package:wordsmith_utils/models/maturity_rating/maturity_rating.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/maturity_ratings_provider.dart';

class EbookFiltersWidget extends StatefulWidget {
  const EbookFiltersWidget({super.key});

  @override
  State<EbookFiltersWidget> createState() => _EbookFiltersWidgetState();
}

class _EbookFiltersWidgetState extends State<EbookFiltersWidget> {
  late MaturityRatingsProvider _maturityRatingsProvider;
  late EbookFilterValuesProvider _ebookFilterValuesProvider;

  late Future<Result<QueryResult<MaturityRating>>> _maturityRatingsFuture;

  Widget _buildHeader() {
    return Row(
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
            setState(() {
              _ebookFilterValuesProvider.clearFilterValues();
            });
          },
          child: const Text("Clear all"),
        ),
      ],
    );
  }

  Widget _buildMaturityRatingSelect() {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("Maturity rating"),
        FutureBuilder(
          future: _maturityRatingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            late List<MaturityRating> maturityRatings;

            switch (snapshot.data!) {
              case Success(data: final d):
                maturityRatings = d.result;
              case Failure(exception: final e):
                return Center(child: Text(e.toString()));
            }

            return Wrap(
              spacing: 8.0,
              children: List<Widget>.generate(maturityRatings.length, (index) {
                var rating = maturityRatings[index];
                var selectedRating = _ebookFilterValuesProvider
                    .filterValues.selectedMaturityRatingId;

                return ChoiceChip(
                  label: Text(rating.name),
                  selected: selectedRating == rating.id,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _ebookFilterValuesProvider.updateFilterValueProperties(
                            selectedMaturityRatingId: rating.id);
                      } else {
                        _ebookFilterValuesProvider.updateFilterValueProperties(
                            selectedMaturityRatingId: null);
                      }
                    });
                  },
                );
              }),
            );
          },
        ),
      ],
    );
  }

  void _getMaturityRatings() {
    _maturityRatingsFuture = _maturityRatingsProvider.getMaturityRatings();
  }

  @override
  void initState() {
    _maturityRatingsProvider = context.read<MaturityRatingsProvider>();
    _ebookFilterValuesProvider = context.read<EbookFilterValuesProvider>();
    _getMaturityRatings();
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
          Builder(builder: (context) => _buildMaturityRatingSelect()),
        ],
      ),
    );
  }
}
