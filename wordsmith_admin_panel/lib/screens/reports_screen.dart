import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/widgets/input_field.dart";
import "package:wordsmith_admin_panel/widgets/pagination_nav.dart";
import "package:wordsmith_admin_panel/widgets/reports_list.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:wordsmith_utils/models/user_report.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";
import "package:wordsmith_utils/providers/user_reports_provider.dart";
import "package:wordsmith_utils/size_config.dart";

class ReportsScreenWidget extends StatefulWidget {
  final _logger = LogManager.getLogger("ReportsScreen");

  ReportsScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ReportsScreenWidgetState();
}

class _ReportsScreenWidgetState extends State<ReportsScreenWidget> {
  late UserLoginProvider _userLoginProvider;
  late UserReportsProvider _userReportsProvider;
  final TextEditingController _searchController = TextEditingController();
  int selectedView = 0;

  int _currentPage = 1;
  int _totalPages = 0;
  int _pageSize = 1;
  late Future<QueryResult<UserReport>?> _userReports;
  // EBookReports should also be a property here when implemented

  @override
  void initState() {
    _userLoginProvider = context.read<UserLoginProvider>();
    _userReportsProvider = context.read<UserReportsProvider>();

    try {
      _userReports = getUserReports();
    } on BaseException catch (error) {
      _userReports = Future.error(error);
    } on Exception catch (error) {
      widget._logger.severe(error);
      _userReports = Future.error(error);
    }

    super.initState();
  }

  Future<QueryResult<UserReport>?> getUserReports() async {
    String? accessToken = await _userLoginProvider.getAccessToken(context);

    if (accessToken == null) return null;

    Map<String, String> queries = {
      "page": _currentPage.toString(),
      "pageSize": _pageSize.toString(),
    };

    var result = await _userReportsProvider.get(
        filter: queries, bearerToken: accessToken);

    _totalPages = result.totalPages!;

    return result;
  }

  void forward() async {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        _userReports = getUserReports();
      });
    }
  }

  void back() async {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _userReports = getUserReports();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                runSpacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  InputField(
                      labelText: "Search", controller: _searchController),
                  SizedBox(
                    width: SizeConfig.safeBlockHorizontal * 1.0,
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                  SizedBox(
                    width: SizeConfig.safeBlockHorizontal * 6.0,
                  ),
                  SegmentedButton(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<int>>[
                      ButtonSegment<int>(value: 0, label: Text("User reports")),
                      ButtonSegment<int>(
                          value: 1, label: Text("eBook reports")),
                    ],
                    selected: <int>{selectedView},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        selectedView = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
            ),
            ReportsListWidget(userReports: _userReports),
            FutureBuilder(
              future: _userReports,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return PaginationNavWidget(
                  currentPage: _currentPage,
                  lastPage: _totalPages,
                  forwardCallback: forward,
                  backCallback: back,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
