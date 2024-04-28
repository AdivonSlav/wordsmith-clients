import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wordsmith_admin_panel/utils/statistics_filter_values.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/ebook/ebook_publish_statistics.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/statistics/statistics_request.dart';
import 'package:wordsmith_utils/providers/ebook_publish_statistics_provider.dart';

class EbookPublishStatisticsViewWidget extends StatefulWidget {
  const EbookPublishStatisticsViewWidget({super.key});

  @override
  State<EbookPublishStatisticsViewWidget> createState() =>
      _EbookPublishStatisticsViewWidgetState();
}

class _EbookPublishStatisticsViewWidgetState
    extends State<EbookPublishStatisticsViewWidget> {
  late EbookPublishStatisticsProvider _publishStatisticsProvider;
  late StatisticsFilterValuesProvider _filterValuesProvider;

  late Future<Result<QueryResult<EbookPublishStatistics>>>
      _publishStatisticsFuture;

  ChartTitle _buildChartTitle() {
    final start = _filterValuesProvider.filterValues.startDate;
    final end = _filterValuesProvider.filterValues.endDate;

    return ChartTitle(
      text:
          "Ebook publishings between ${formatDateTime(date: start, format: "yMMMd")} and ${formatDateTime(date: end, format: "yMMMd")}",
    );
  }

  Widget _buildChart(List<EbookPublishStatistics> statistics) {
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
          LineSeries<EbookPublishStatistics, DateTime>(
            enableTooltip: true,
            name: "Ebook publishings",
            dataSource: statistics,
            xValueMapper: (statistic, _) => statistic.date,
            yValueMapper: (statistic, _) => statistic.publishCount,
          ),
        ],
      ),
    );
  }

  void _getPublishStatistics() {
    var request = StatisticsRequest(
      startDate: _filterValuesProvider.filterValues.startDate,
      endDate: _filterValuesProvider.filterValues.endDate,
    );

    setState(() {
      _publishStatisticsFuture =
          _publishStatisticsProvider.getPublishStatistics(
        request,
        pageSize: _filterValuesProvider.filterValues.limit,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterValuesProvider.addListener(_getPublishStatistics);
  }

  @override
  void dispose() {
    _filterValuesProvider.removeListener(_getPublishStatistics);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EbookPublishStatisticsViewWidget oldWidget) {
    _getPublishStatistics();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _publishStatisticsProvider = context.read<EbookPublishStatisticsProvider>();
    _filterValuesProvider = context.read<StatisticsFilterValuesProvider>();

    _getPublishStatistics();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _publishStatisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text(snapshot.error?.toString() ?? "Error"));
        }

        late List<EbookPublishStatistics> statistics;

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
