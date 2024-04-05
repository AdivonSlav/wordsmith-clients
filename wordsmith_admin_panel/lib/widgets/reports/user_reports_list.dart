import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_admin_panel/utils/reports_filter_values.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/models/user_report/user_report.dart';
import 'package:wordsmith_utils/models/user_report/user_report_search.dart';
import 'package:wordsmith_utils/providers/user_reports_provider.dart';

class UserReportsListWidget extends StatefulWidget {
  const UserReportsListWidget({super.key});

  @override
  State<UserReportsListWidget> createState() => _UserReportsListWidgetState();
}

class _UserReportsListWidgetState extends State<UserReportsListWidget> {
  late UserReportsProvider _userReportsProvider;
  late ReportFilterValuesProvider _filterValuesProvider;

  late Future<Result<QueryResult<UserReport>>> _userReportsFuture;

  int _page = 1;
  int _pageSize = 10;
  int _totalPages = 0;
  int _totalCount = 0;

  Widget _buildList() {
    return FutureBuilder(
      future: _userReportsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text(snapshot.error?.toString() ?? "Error"));
        }

        late List<UserReport> reports;

        switch (snapshot.data!) {
          case Success(data: final d):
            _setPaginationDetails(d);
            reports = d.result;
          case Failure(exception: final e):
            return Center(child: Text(e.message));
        }

        if (reports.isEmpty) {
          return const Center(child: Text("No reports found!"));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  var report = reports[index];

                  return Card(
                    child: ListTile(
                      title: Text(report.reportDetails.reportReason.reason),
                      leading: report.reportDetails.isClosed
                          ? const Icon(Icons.check)
                          : const Icon(Icons.warning),
                      isThreeLine: true,
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Submitted by ${report.reportDetails.reporter.username}"),
                          Text(
                            formatDateTime(
                              date: report.reportDetails.submissionDate,
                              format: "MMM d, y H:mm",
                            ),
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text("Number of reports: $_totalCount"),
        const Spacer(),
        Row(
          children: [
            IconButton(
              onPressed: () => _back(),
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            Text("$_page / $_totalPages"),
            IconButton(
              onPressed: () => _next(),
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: <Widget>[
            const Text("Show entries:"),
            const SizedBox(width: 10.0),
            SizedBox(
              width: 75.0,
              child: DropdownButton(
                value: _pageSize,
                isExpanded: true,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _pageSize = value;
                      _getUserReports();
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 10,
                    child: Text("10"),
                  ),
                  DropdownMenuItem(
                    value: 50,
                    child: Text("50"),
                  ),
                  DropdownMenuItem(
                    value: 100,
                    child: Text("100"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _next() {
    if (_page < _totalPages) {
      setState(() {
        _page++;
        _getUserReports();
      });
    }
  }

  void _back() {
    if (_page > 1) {
      setState(() {
        _page--;
        _getUserReports();
      });
    }
  }

  UserReportSearch _getReportSearch() {
    return UserReportSearch(
      isClosed: _filterValuesProvider.filterValues.isClosed,
      reportDate: _filterValuesProvider.filterValues.reportDate,
      reason: _filterValuesProvider.filterValues.reason,
    );
  }

  void _getUserReports() async {
    var sort = _filterValuesProvider.filterValues.sort;
    var direction = _filterValuesProvider.filterValues.sortDirection;
    var search = _getReportSearch();
    _userReportsFuture = _userReportsProvider.getUserReports(
      search,
      page: _page,
      pageSize: _pageSize,
      orderBy: "${sort.apiValue}:${direction.apiValue}",
    );
  }

  void _setPaginationDetails(QueryResult<UserReport> reports) async {
    if (!mounted) return;

    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    setState(() {
      _totalCount = reports.totalCount!;
      _totalPages = reports.totalPages!;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterValuesProvider.addListener(_getUserReports);
  }

  @override
  void dispose() {
    _filterValuesProvider.removeListener(_getUserReports);
    _filterValuesProvider.clearFilterValues(notify: false);
    super.dispose();
  }

  @override
  void initState() {
    _userReportsProvider = context.read<UserReportsProvider>();
    _filterValuesProvider = context.read<ReportFilterValuesProvider>();
    _getUserReports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Builder(builder: (context) => _buildList()),
        ),
        const Divider(),
        Builder(builder: (context) => _buildPagination()),
      ],
    );
  }
}
