import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/filters/ebook_filter_values.dart';
import 'package:wordsmith_mobile/widgets/home/home_ebook_display.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/ebook/ebook_search.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  late EbookProvider _eBookProvider;

  late Future<Result<QueryResult<Ebook>>> _newlyAddedFuture;
  late Future<Result<QueryResult<Ebook>>> _mostPopularFuture;

  final _page = 1;
  final _pageSize = 10;

  Widget _buildNewlyAddedDisplay() {
    return FutureBuilder(
      future: _newlyAddedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        late List<Ebook> ebooks;

        switch (snapshot.data!) {
          case Success(data: final d):
            ebooks = d.result;
          case Failure(exception: final e):
            return Center(child: Text(e.toString()));
        }

        return HomeEbookDisplayWidget(
          title: "New",
          ebooks: ebooks,
        );
      },
    );
  }

  Widget _buildMostPopularDisplay() {
    return FutureBuilder(
      future: _mostPopularFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        late List<Ebook> ebooks;

        switch (snapshot.data!) {
          case Success(data: final d):
            ebooks = d.result;
          case Failure(exception: final e):
            return Center(child: Text(e.toString()));
        }

        return HomeEbookDisplayWidget(
          title: "Most popular",
          ebooks: ebooks,
        );
      },
    );
  }

  Future<void> _refresh() async {
    var search = const EbookSearch();

    setState(() {
      _newlyAddedFuture = _eBookProvider.getEbooks(
        search,
        page: _page,
        pageSize: _pageSize,
        orderBy:
            "${EbookSorts.publicationDate.apiValue}:${SortDirections.descending.apiValue}",
      );

      _mostPopularFuture = _eBookProvider.getEbooks(
        search,
        page: _page,
        pageSize: _pageSize,
        orderBy:
            "${EbookSorts.syncCount.apiValue}:${SortDirections.descending.apiValue}",
      );
    });
  }

  @override
  void initState() {
    _eBookProvider = context.read<EbookProvider>();
    _refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0),
      child: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Builder(builder: (context) => _buildNewlyAddedDisplay()),
              const Divider(),
              Builder(builder: (context) => _buildMostPopularDisplay()),
            ],
          ),
        ),
      ),
    );
  }
}
