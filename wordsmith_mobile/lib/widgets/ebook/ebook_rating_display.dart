import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/ebook_rating/ebook_rating.dart';
import 'package:wordsmith_utils/models/ebook_rating/ebook_rating_insert.dart';
import 'package:wordsmith_utils/models/ebook_rating/ebook_rating_statistics.dart';
import 'package:wordsmith_utils/models/ebook_rating/ebook_rating_update.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/ebook_rating_provider.dart';
import 'package:wordsmith_utils/providers/ebook_rating_statistics_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class EbookRatingDisplayWidget extends StatefulWidget {
  final Ebook ebook;
  final bool isInLibrary;

  const EbookRatingDisplayWidget({
    super.key,
    required this.ebook,
    required this.isInLibrary,
  });

  @override
  State<EbookRatingDisplayWidget> createState() =>
      _EbookRatingDisplayWidgetState();
}

class _EbookRatingDisplayWidgetState extends State<EbookRatingDisplayWidget> {
  late EbookRatingProvider _ebookRatingProvider;
  late EbookRatingStatisticsProvider _ebookRatingStatisticsProvider;
  late Future<Result<QueryResult<EbookRatingStatistics>>> _statisticsFuture;

  final Color _starColor = const Color(0xFFFF9529);
  bool _isRatingInProgress = false;

  Widget _buildRatingSummary() {
    return FutureBuilder(
        future: _statisticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data;

          if (data == null || snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          late EbookRatingStatistics statistics;

          switch (data) {
            case Success():
              statistics = data.data.result.first;
            case Failure(exception: final e):
              return Center(child: Text(e.message));
          }

          return Row(
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    final int ratingIndex = (index - 6 + 1).abs();
                    final int? ratingCount =
                        statistics.ratingCounts[ratingIndex];
                    double ratingProportion = 0.0;

                    if (ratingCount != null &&
                        statistics.totalRatingCount > 0) {
                      ratingProportion =
                          ratingCount / statistics.totalRatingCount;
                    }

                    // String ratingPercentage =
                    //     "${(ratingProportion * 100.00).toStringAsFixed(0)}%";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(ratingIndex.toString()),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: LinearProgressIndicator(
                              borderRadius: BorderRadius.circular(10.0),
                              minHeight: 6.0,
                              color: _starColor,
                              value: ratingProportion.isFinite
                                  ? ratingProportion
                                  : 0.0,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          // Text(ratingPercentage),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      statistics.ratingAverage.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RatingBar.builder(
                      ignoreGestures: true,
                      allowHalfRating: true,
                      itemSize: 30.0,
                      maxRating: 5.0,
                      minRating: 1.0,
                      initialRating: statistics.ratingAverage,
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: _starColor),
                      onRatingUpdate: (rating) {},
                    ),
                    Text(
                      "${statistics.totalRatingCount} ratings",
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _buildRatingAdd() {
    if (!widget.isInLibrary) {
      return const Center(
        child: Text(
          "To rate this ebook, you need to add it to your library first",
          textAlign: TextAlign.center,
        ),
      );
    }

    return FutureBuilder(
      future: _getRatingForCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        var data = snapshot.data;

        if (data == null || snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        EbookRating? userRating;

        switch (data) {
          case Success(data: final d):
            if (d.result.isNotEmpty) userRating = d.result.first;
          case Failure(exception: final e):
            return Center(child: Text(e.message));
        }

        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Your rating: ",
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            RatingBar.builder(
              itemSize: 35.0,
              initialRating:
                  userRating != null ? userRating.rating.toDouble() : 0.0,
              glow: false,
              maxRating: 5.0,
              minRating: 1.0,
              itemBuilder: (context, _) => Icon(Icons.star, color: _starColor),
              onRatingUpdate: (rating) => _addRating(
                userRating,
                rating.toInt(),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Result<QueryResult<EbookRating>>> _getRatingForCurrentUser() async {
    var userId = await SecureStore.getValue("user_ref_id");
    return _ebookRatingProvider.getRatings(
      userId: int.tryParse(userId ?? ""),
      ebookId: widget.ebook.id,
    );
  }

  void _getRatingStatistics() async {
    _statisticsFuture =
        _ebookRatingStatisticsProvider.getStatistics(widget.ebook.id);
  }

  void _addRating(EbookRating? userRating, int newRating) async {
    if (_isRatingInProgress) return;
    setState(() {
      _isRatingInProgress = true;
    });

    if (userRating != null) {
      var update = EbookRatingUpdate(rating: newRating);
      await _ebookRatingProvider
          .updateRating(ratingId: userRating.id, update: update)
          .then((result) {
        setState(() {
          _isRatingInProgress = false;
        });
        switch (result) {
          case Success():
            _getRatingStatistics();
          case Failure(exception: final e):
            showSnackbar(context: context, content: e.toString());
        }
      });
    } else {
      var insert =
          EbookRatingInsert(rating: newRating, ebookId: widget.ebook.id);
      await _ebookRatingProvider.addRating(insert).then((result) {
        setState(() {
          _isRatingInProgress = false;
        });
        switch (result) {
          case Success():
            _getRatingStatistics();
          case Failure(exception: final e):
            showSnackbar(context: context, content: e.toString());
        }
      });
    }
  }

  @override
  void initState() {
    _ebookRatingProvider = context.read<EbookRatingProvider>();
    _ebookRatingStatisticsProvider =
        context.read<EbookRatingStatisticsProvider>();

    _getRatingStatistics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.all(24.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: size.height * 0.50,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: constraints.maxHeight * 0.60,
                    child: _buildRatingSummary(),
                  ),
                  const Divider(height: 1.0),
                  const Spacer(),
                  SizedBox(
                    height: constraints.maxHeight * 0.10,
                    child: _buildRatingAdd(),
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
