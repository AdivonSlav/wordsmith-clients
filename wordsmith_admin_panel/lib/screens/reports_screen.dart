import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/widgets/input_field.dart";
import "package:wordsmith_admin_panel/widgets/loading.dart";
import "package:wordsmith_admin_panel/widgets/pagination_nav.dart";
import "package:wordsmith_admin_panel/widgets/reports/reports_list.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/ebook_report/ebook_report.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/user_report/user_report.dart";
import "package:wordsmith_utils/providers/ebook_reports_provider.dart";
import "package:wordsmith_utils/providers/user_reports_provider.dart";
import "package:wordsmith_utils/size_config.dart";

class ReportsScreenWidget extends StatefulWidget {
  final _logger = LogManager.getLogger("ReportsScreen");

  ReportsScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ReportsScreenWidgetState();
}

class _ReportsScreenWidgetState extends State<ReportsScreenWidget> {
  late UserReportsProvider _userReportsProvider;
  late EbookReportsProvider _eBookReportsProvider;
  final TextEditingController _reasonFilterController = TextEditingController();
  int selectedView = 0;

  int _currentPage = 1;
  int _totalPages = 0;
  final int _pageSize = 10;
  late Future<Result<QueryResult<UserReport>>> _userReports;
  late Future<Result<QueryResult<EbookReport>>> _eBookReports;

  void getUserReports({String? reason, DateTime? reportDate}) async {
    _userReports = _userReportsProvider.getUserReports(
      page: _currentPage,
      pageSize: _pageSize,
      reason: reason,
      reportDate: reportDate,
    );
  }

  void getEBookReports({String? reason, DateTime? reportDate}) async {
    _eBookReports = _eBookReportsProvider.getEBookReports(
      page: _currentPage,
      pageSize: _pageSize,
      reason: reason,
      reportDate: reportDate,
    );
  }

  void forward() async {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        getUserReports();
      });
    }
  }

  void back() async {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        if (selectedView == 0) {
          getUserReports();
        } else {
          getEBookReports();
        }
      });
    }
  }

  void filterByReason() {
    var filter = _reasonFilterController.text;

    if (selectedView == 0) {
      setState(() {
        getUserReports(reason: filter);
        widget._logger.info("Got new user reports from reason filtering!");
      });
    } else if (selectedView == 1) {
      setState(() {
        getEBookReports(reason: filter);
        widget._logger.info("Got new ebook reports from reason filtering!");
      });
    }
  }

  void filterByDate() async {
    var filter = await showDatePicker(
      context: context,
      firstDate: DateTime(2001),
      lastDate: DateTime(2101),
    );

    if (filter != null && filter != DateTime.now()) {
      if (selectedView == 0) {
        setState(() {
          getUserReports(reportDate: filter);
          widget._logger.info("Got new user reports from date filtering!");
        });
      } else if (selectedView == 1) {
        setState(() {
          getEBookReports(reportDate: filter);
          widget._logger.info("Got new ebook reports from date filtering!");
        });
      }
    }
  }

  void clearAllFilters() {
    _reasonFilterController.clear();

    setState(() {
      if (selectedView == 0) {
        setState(() {
          _userReports = _userReportsProvider.getUserReports(
              page: _currentPage, pageSize: _pageSize);
          widget._logger.info("Cleared all filters for user reports!");
        });
      } else if (selectedView == 1) {
        setState(() {
          _eBookReports = _eBookReportsProvider.getEBookReports(
              page: _currentPage, pageSize: _pageSize);
          widget._logger.info("Cleared all filters for ebook reports!");
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _userReportsProvider = context.read<UserReportsProvider>();
    _eBookReportsProvider = context.read<EbookReportsProvider>();

    _userReports = _userReportsProvider.getUserReports(
        page: _currentPage, pageSize: _pageSize);
    _eBookReports = _eBookReportsProvider.getEBookReports(
        page: _currentPage, pageSize: _pageSize);
  }

  @override
  Widget build(BuildContext context) {
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
                      labelText: "Reason", controller: _reasonFilterController),
                  SizedBox(
                    width: SizeConfig.safeBlockHorizontal * 1.0,
                  ),
                  IconButton(
                    onPressed: () {
                      filterByReason();
                    },
                    icon: const Icon(Icons.search),
                    tooltip: "Search by reason",
                  ),
                  SizedBox(
                    width: SizeConfig.safeBlockHorizontal * 1.0,
                  ),
                  IconButton(
                    onPressed: () async {
                      filterByDate();
                    },
                    icon: const Icon(Icons.edit_calendar),
                    tooltip: "Filter date",
                  ),
                  SizedBox(
                    width: SizeConfig.safeBlockHorizontal * 1.0,
                  ),
                  IconButton(
                    onPressed: () {
                      clearAllFilters();
                    },
                    icon: const Icon(Icons.clear),
                    tooltip: "Clear all filters",
                  ),
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
                        _reasonFilterController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
            ReportsListWidget(
                reports: selectedView == 0 ? _userReports : _eBookReports),
            FutureBuilder(
              future: selectedView == 0 ? _userReports : _eBookReports,
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingWidget();
                }

                if (selectedView == 0) {
                  var snapshotData =
                      snapshot.data as Result<QueryResult<UserReport>>;

                  switch (snapshotData) {
                    case Success(data: final d):
                      _totalPages = d.totalPages!;
                    case Failure(exception: final e):
                      return Center(child: Text(e.toString()));
                  }
                } else if (selectedView == 1) {
                  var snapshotData =
                      snapshot.data as Result<QueryResult<EbookReport>>;

                  switch (snapshotData) {
                    case Success(data: final d):
                      _totalPages = d.totalPages!;
                    case Failure(exception: final e):
                      return Center(child: Text(e.toString()));
                  }
                }

                _totalPages = selectedView == 0
                    ? (snapshot.data as QueryResult<UserReport>).totalPages!
                    : (snapshot.data as QueryResult<EbookReport>).totalPages!;

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
