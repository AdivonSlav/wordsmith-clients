import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/home/home_ebook_display.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  late EBookProvider _eBookProvider;

  late Future<Result<QueryResult<EBook>>> _getNewlyAddedBooks;

  final _page = 1;
  final _pageSize = 15;

  @override
  void initState() {
    super.initState();
    _eBookProvider = context.read<EBookProvider>();
    _getNewlyAddedBooks =
        _eBookProvider.getNewlyAdded(page: _page, pageSize: _pageSize);
  }

  @override
  Widget build(BuildContext context) {
    _eBookProvider = context.read<EBookProvider>();

    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0),
      child: Column(
        children: <Widget>[
          FutureBuilder(
            future: _getNewlyAddedBooks,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              List<EBook> ebooks = [];

              switch (snapshot.data!) {
                case Success(data: final d):
                  ebooks = d.result;
                case Failure(exception: final e):
                  return Center(child: Text(e.toString()));
              }

              return HomeEBookDisplayWidget(
                title: "New",
                ebooks: ebooks,
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
