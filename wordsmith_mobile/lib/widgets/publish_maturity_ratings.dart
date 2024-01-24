import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/maturity_rating.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/providers/maturity_ratings_provider.dart';

class PublishMaturityRatingsWidget extends StatefulWidget {
  final void Function(MaturityRating rating) onMaturityRatingSelect;

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
  int? _selectedIndex = 0;

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
      _selectedIndex = selected ? index : null;
      widget.onMaturityRatingSelect(_maturityRatings[index]);
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

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (var i = 0; i < _maturityRatings.length; i++)
                    Expanded(
                      child: ChoiceChip(
                        label: Text(_maturityRatings[i].name),
                        selected: _selectedIndex == i,
                        onSelected: (bool selected) => _onSelected(selected, i),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }
}
