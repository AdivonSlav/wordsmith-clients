import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/maturity_rating.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/providers/maturity_ratings_provider.dart';

class PublishMaturityRatingsWidget extends StatefulWidget {
  final void Function(MaturityRating? rating) onMaturityRatingSelect;

  const PublishMaturityRatingsWidget({
    super.key,
    required this.onMaturityRatingSelect,
  });

  @override
  State<StatefulWidget> createState() => _PublishMaturityRatingsWidgetState();
}

class _PublishMaturityRatingsWidgetState
    extends State<PublishMaturityRatingsWidget> {
  final _logger = LogManager.getLogger("PublishMaturityRatings");

  late MaturityRatingsProvider _maturityRatingsProvider;
  late Future<QueryResult<MaturityRating>> _getMaturityRatingsFuture;

  List<MaturityRating> _maturityRatings = [];
  int? _selectedIndex;

  Future<QueryResult<MaturityRating>> _loadMaturityRatings() async {
    try {
      var result = await _maturityRatingsProvider.getMaturityRatings();

      return result;
    } on BaseException catch (error) {
      _logger.info(error);
      return Future.error(error);
    } on Exception catch (error) {
      _logger.severe(error);
      return Future.error(error);
    }
  }

  void _onSelected(bool selected, int index) {
    setState(() {
      if (selected == true) {
        _selectedIndex = index;
        widget.onMaturityRatingSelect(_maturityRatings[_selectedIndex!]);
      } else {
        _selectedIndex = null;
        widget.onMaturityRatingSelect(null);
      }
    });
  }

  @override
  void initState() {
    _maturityRatingsProvider = context.read<MaturityRatingsProvider>();
    _getMaturityRatingsFuture = _loadMaturityRatings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return FutureBuilder(
        future: _getMaturityRatingsFuture,
        builder:
            (context, AsyncSnapshot<QueryResult<MaturityRating>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Text(snapshot.error.toString());
          }

          _maturityRatings = snapshot.data!.result;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  "Choose a maturity rating",
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
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          children: List<Widget>.generate(
                              _maturityRatings.length, (index) {
                            return ChoiceChip(
                              label: Text(_maturityRatings[index].name),
                              selected: _selectedIndex == index,
                              onSelected: (bool selected) =>
                                  _onSelected(selected, index),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}
