import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/home_ebook_display.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  final _logger = LogManager.getLogger("HomeScreen");
  late EBookProvider _eBookProvider;

  Future<QueryResult<EBook>> _getNewlyAddedEBooks() async {
    try {
      var ebooks = await _eBookProvider.getNewlyAdded(page: 1, pageSize: 15);

      return ebooks;
    } on BaseException catch (error) {
      _logger.info(error);
      return Future.error(error);
    } on Exception catch (error) {
      _logger.severe(error);
      return Future.error(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    _eBookProvider = context.read<EBookProvider>();

    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0),
      child: Column(
        children: <Widget>[
          FutureBuilder(
            future: _getNewlyAddedEBooks(),
            builder: (context, AsyncSnapshot<QueryResult<EBook>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return const Text("Could not load!");
              }

              var ebooks = snapshot.data!.result;

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
