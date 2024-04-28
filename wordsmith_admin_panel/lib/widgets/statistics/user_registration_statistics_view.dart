import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wordsmith_admin_panel/utils/statistics_filter_values.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/statistics/statistics_request.dart';
import 'package:wordsmith_utils/models/user/user_registration_statistics.dart';
import 'package:wordsmith_utils/providers/user_registration_statistics_provider.dart';

class UserRegistrationStatisticsViewWidget extends StatefulWidget {
  const UserRegistrationStatisticsViewWidget({super.key});

  @override
  State<UserRegistrationStatisticsViewWidget> createState() =>
      _UserRegistrationStatisticsViewWidgetState();
}

class _UserRegistrationStatisticsViewWidgetState
    extends State<UserRegistrationStatisticsViewWidget> {
  late UserRegistrationStatisticsProvider _registrationStatisticsProvider;
  late StatisticsFilterValuesProvider _filterValuesProvider;

  late Future<Result<QueryResult<UserRegistrationStatistics>>>
      _registrationStatisticsFuture;

  ChartTitle _buildChartTitle() {
    final start = _filterValuesProvider.filterValues.startDate;
    final end = _filterValuesProvider.filterValues.endDate;

    return ChartTitle(
      text:
          "Registrations between ${formatDateTime(date: start, format: "yMMMd")} and ${formatDateTime(date: end, format: "yMMMd")}",
    );
  }

  Widget _buildChart(List<UserRegistrationStatistics> statistics) {
    return Center(
      child: SfCartesianChart(
        title: _buildChartTitle(),
        primaryXAxis: const DateTimeAxis(
          intervalType: DateTimeIntervalType.auto,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          decimalPlaces: 0,
        ),
        legend: const Legend(isVisible: true),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          duration: 2000,
        ),
        series: <CartesianSeries>[
          LineSeries<UserRegistrationStatistics, DateTime>(
            enableTooltip: true,
            name: "Number of registrations",
            dataSource: statistics,
            xValueMapper: (statistic, _) => statistic.date.toLocal(),
            yValueMapper: (statistic, _) => statistic.registrationCount,
          )
        ],
      ),
    );
  }

  void _getRegistrationStatistics() {
    var request = StatisticsRequest(
      startDate: _filterValuesProvider.filterValues.startDate,
      endDate: _filterValuesProvider.filterValues.endDate,
    );

    setState(() {
      _registrationStatisticsFuture =
          _registrationStatisticsProvider.getRegistrationStatistics(request,
              pageSize: _filterValuesProvider.filterValues.limit);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterValuesProvider.addListener(_getRegistrationStatistics);
  }

  @override
  void dispose() {
    _filterValuesProvider.removeListener(_getRegistrationStatistics);
    super.dispose();
  }

  @override
  void didUpdateWidget(
      covariant UserRegistrationStatisticsViewWidget oldWidget) {
    _getRegistrationStatistics();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _registrationStatisticsProvider =
        context.read<UserRegistrationStatisticsProvider>();
    _filterValuesProvider = context.read<StatisticsFilterValuesProvider>();

    _getRegistrationStatistics();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _registrationStatisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text(snapshot.error?.toString() ?? "Error"));
        }

        late List<UserRegistrationStatistics> statistics;

        switch (snapshot.data!) {
          case Success(data: final d):
            statistics = d.result;
          case Failure(exception: final e):
            return Center(child: Text(e.message));
        }

        if (statistics.isEmpty) {
          return const Center(child: Text("No statistics found!"));
        }

        return Builder(builder: (context) => _buildChart(statistics));
      },
    );
  }
}
