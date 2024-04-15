import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_admin_panel/screens/reports_screen.dart';
import 'package:wordsmith_admin_panel/utils/reports_filter_values.dart';
import 'package:wordsmith_admin_panel/widgets/reports/app_report_dialog.dart';
import 'package:wordsmith_admin_panel/widgets/reports/ebook_report_dialog.dart';
import 'package:wordsmith_admin_panel/widgets/reports/user_report_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/app_report/app_report.dart';
import 'package:wordsmith_utils/models/app_report/app_report_search.dart';
import 'package:wordsmith_utils/models/ebook_report/ebook_report.dart';
import 'package:wordsmith_utils/models/ebook_report/ebook_report_search.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/models/user_report/user_report.dart';
import 'package:wordsmith_utils/models/user_report/user_report_search.dart';
import 'package:wordsmith_utils/providers/app_report_provider.dart';
import 'package:wordsmith_utils/providers/ebook_reports_provider.dart';
import 'package:wordsmith_utils/providers/user_reports_provider.dart';

class ReportsListWidget extends StatefulWidget {
  final ReportType type;

  const ReportsListWidget({super.key, required this.type});

  @override
  State<ReportsListWidget> createState() => _ReportsListWidgetState();
}

class _ReportsListWidgetState extends State<ReportsListWidget> {
  late UserReportsProvider _userReportsProvider;
  late EbookReportsProvider _ebookReportsProvider;
  late AppReportProvider _appReportProvider;
  late ReportFilterValuesProvider _filterValuesProvider;

  late Future<Result<QueryResult<UserReport>>> _userReportsFuture;
  late Future<Result<QueryResult<EbookReport>>> _ebookReportsFuture;
  late Future<Result<QueryResult<AppReport>>> _appReportsFuture;

  int _page = 1;
  int _pageSize = 10;
  int _totalPages = 0;
  int _totalCount = 0;

  Widget _buildUserReportsList() {
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
            _setPaginationDetails(d.totalCount!, d.totalPages!);
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
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) =>
                              UserReportDialogWidget(reportId: report.id),
                        );
                      },
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

  Widget _buildEbookReportsList() {
    return FutureBuilder(
      future: _ebookReportsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text(snapshot.error?.toString() ?? "Error"));
        }

        late List<EbookReport> reports;

        switch (snapshot.data!) {
          case Success(data: final d):
            _setPaginationDetails(d.totalCount!, d.totalPages!);
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
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) =>
                              EbookReportDialogWidget(reportId: report.id),
                        );
                      },
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

  Widget _buildAppReportsList() {
    return FutureBuilder(
      future: _appReportsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text(snapshot.error?.toString() ?? "Error"));
        }

        late List<AppReport> reports;

        switch (snapshot.data!) {
          case Success(data: final d):
            _setPaginationDetails(d.totalCount!, d.totalPages!);
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
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) =>
                              AppReportDialogWidget(reportId: report.id),
                        );
                      },
                      title: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Report by ${report.user.username}"),
                          Text(
                            formatDateTime(
                              date: report.submissionDate,
                              format: "MMM d, y H:mm",
                            ),
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      leading: report.isClosed
                          ? const Icon(Icons.check)
                          : const Icon(Icons.warning),
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

  Widget _buildList() {
    switch (widget.type) {
      case ReportType.user:
        return _buildUserReportsList();
      case ReportType.ebook:
        return _buildEbookReportsList();
      case ReportType.app:
        return _buildAppReportsList();
    }
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
                      _refresh();
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
        _refresh();
      });
    }
  }

  void _back() {
    if (_page > 1) {
      setState(() {
        _page--;
        _refresh();
      });
    }
  }

  UserReportSearch _getUserReportSearch() {
    return UserReportSearch(
      isClosed: _filterValuesProvider.filterValues.isClosed,
      startDate: _filterValuesProvider.filterValues.startDate,
      endDate: _filterValuesProvider.filterValues.endDate,
      reason: _filterValuesProvider.filterValues.reason,
    );
  }

  EbookReportSearch _getEbookReportSearch() {
    return EbookReportSearch(
      isClosed: _filterValuesProvider.filterValues.isClosed,
      startDate: _filterValuesProvider.filterValues.startDate,
      endDate: _filterValuesProvider.filterValues.endDate,
      reason: _filterValuesProvider.filterValues.reason,
    );
  }

  AppReportSearch _getAppReportSearch() {
    return AppReportSearch(
      isClosed: _filterValuesProvider.filterValues.isClosed,
      startDate: _filterValuesProvider.filterValues.startDate,
      endDate: _filterValuesProvider.filterValues.endDate,
    );
  }

  void _getUserReports() async {
    var sort = _filterValuesProvider.filterValues.sort;
    var direction = _filterValuesProvider.filterValues.sortDirection;
    var search = _getUserReportSearch();
    _userReportsFuture = _userReportsProvider.getUserReports(
      search,
      page: _page,
      pageSize: _pageSize,
      orderBy: "${sort.apiValue}:${direction.apiValue}",
    );
  }

  void _getEbookReports() async {
    var sort = _filterValuesProvider.filterValues.sort;
    var direction = _filterValuesProvider.filterValues.sortDirection;
    var search = _getEbookReportSearch();
    _ebookReportsFuture = _ebookReportsProvider.getEbookReports(
      search,
      page: _page,
      pageSize: _pageSize,
      orderBy: "${sort.apiValue}:${direction.apiValue}",
    );
  }

  void _getAppReports() async {
    var sort = _filterValuesProvider.filterValues.sort;
    var direction = _filterValuesProvider.filterValues.sortDirection;
    var search = _getAppReportSearch();
    String? sortValue;

    if (sort == ReportSorts.mostRecent) {
      sortValue = "SubmissionDate";
    }

    _appReportsFuture = _appReportProvider.getAppReports(
      search,
      page: _page,
      pageSize: _pageSize,
      orderBy: "${sortValue ?? sort.apiValue}:${direction.apiValue}",
    );
  }

  void _refresh() async {
    switch (widget.type) {
      case ReportType.user:
        _getUserReports();
      case ReportType.ebook:
        _getEbookReports();
      case ReportType.app:
        _getAppReports();
    }
  }

  void _setPaginationDetails(int totalCount, int totalPages) async {
    if (!mounted) return;

    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    setState(() {
      _totalCount = totalCount;
      _totalPages = totalPages;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterValuesProvider.addListener(_refresh);
  }

  @override
  void dispose() {
    _filterValuesProvider.removeListener(_refresh);
    _filterValuesProvider.clearFilterValues(notify: false);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReportsListWidget oldWidget) {
    _refresh();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _userReportsProvider = context.read<UserReportsProvider>();
    _ebookReportsProvider = context.read<EbookReportsProvider>();
    _appReportProvider = context.read<AppReportProvider>();
    _filterValuesProvider = context.read<ReportFilterValuesProvider>();
    _refresh();
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
