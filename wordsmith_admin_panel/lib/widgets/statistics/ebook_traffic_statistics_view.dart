import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wordsmith_admin_panel/utils/statistics_filter_values.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/ebook/ebook_traffic_statistics.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/statistics/statistics_request.dart';
import 'package:wordsmith_utils/providers/ebook_traffic_statistics_provider.dart';

class EbookTrafficStatisticsViewWidget extends StatefulWidget {
  const EbookTrafficStatisticsViewWidget({super.key});

  @override
  State<EbookTrafficStatisticsViewWidget> createState() =>
      _EbookTrafficStatisticsViewWidgetState();
}

class _EbookTrafficStatisticsViewWidgetState
    extends State<EbookTrafficStatisticsViewWidget> {
  late EbookTrafficStatisticsProvider _trafficStatisticsProvider;
  late StatisticsFilterValuesProvider _filterValuesProvider;

  late Future<Result<QueryResult<EbookTrafficStatistics>>>
      _trafficStatisticsFuture;

  ChartTitle _buildChartTitle() {
    final start = _filterValuesProvider.filterValues.startDate;
    final end = _filterValuesProvider.filterValues.endDate;

    return ChartTitle(
      text:
          "Ebook traffic (syncs per ebook) between ${formatDateTime(date: start, format: "yMMMd")} and ${formatDateTime(date: end, format: "yMMMd")}",
    );
  }

  Widget _buildChart(List<EbookTrafficStatistics> statistics) {
    return Center(
      child: SfCartesianChart(
        title: _buildChartTitle(),
        primaryXAxis: const CategoryAxis(),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          duration: 2000,
        ),
        series: <CartesianSeries>[
          BarSeries<EbookTrafficStatistics, String>(
            enableTooltip: true,
            name: "Syncs",
            borderRadius: BorderRadius.circular(6.0),
            dataSource: statistics,
            xValueMapper: (statistic, _) => statistic.title,
            yValueMapper: (statistic, _) => statistic.syncCount,
            sortingOrder: SortingOrder.ascending,
            sortFieldValueMapper: (statistic, _) => statistic.syncCount,
          )
        ],
      ),
    );
  }

  void _getTrafficStatistics() {
    var request = StatisticsRequest(
      startDate: _filterValuesProvider.filterValues.startDate,
      endDate: _filterValuesProvider.filterValues.endDate,
    );

    setState(() {
      _trafficStatisticsFuture =
          _trafficStatisticsProvider.getTrafficStatistics(
        request,
        pageSize: _filterValuesProvider.filterValues.limit,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterValuesProvider.addListener(_getTrafficStatistics);
  }

  @override
  void dispose() {
    _filterValuesProvider.removeListener(_getTrafficStatistics);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EbookTrafficStatisticsViewWidget oldWidget) {
    _getTrafficStatistics();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _trafficStatisticsProvider = context.read<EbookTrafficStatisticsProvider>();
    _filterValuesProvider = context.read<StatisticsFilterValuesProvider>();

    _getTrafficStatistics();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _trafficStatisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text(snapshot.error?.toString() ?? "Error"));
        }

        late List<EbookTrafficStatistics> statistics;

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
