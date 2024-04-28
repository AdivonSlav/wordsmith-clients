import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wordsmith_admin_panel/utils/statistics_filter_values.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/statistics/statistics_request.dart';
import 'package:wordsmith_utils/models/user/user_purchases_statistics.dart';
import 'package:wordsmith_utils/providers/user_purchase_statistics_provider.dart';

class UserPurchaseStatisticsViewWidget extends StatefulWidget {
  const UserPurchaseStatisticsViewWidget({super.key});

  @override
  State<UserPurchaseStatisticsViewWidget> createState() =>
      _UserPurchaseStatisticsViewWidgetState();
}

class _UserPurchaseStatisticsViewWidgetState
    extends State<UserPurchaseStatisticsViewWidget> {
  late UserPurchaseStatisticsProvider _purchaseStatisticsProvider;
  late StatisticsFilterValuesProvider _filterValuesProvider;

  late Future<Result<QueryResult<UserPurchasesStatistics>>>
      _purchaseStatisticsFuture;

  ChartTitle _buildChartTitle() {
    final start = _filterValuesProvider.filterValues.startDate;
    final end = _filterValuesProvider.filterValues.endDate;

    return ChartTitle(
      text:
          "User purchases between ${formatDateTime(date: start, format: "yMMMd")} and ${formatDateTime(date: end, format: "yMMMd")}",
    );
  }

  Widget _buildChart(List<UserPurchasesStatistics> statistics) {
    return Center(
      child: SfCartesianChart(
        title: _buildChartTitle(),
        primaryXAxis: const CategoryAxis(),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.currency(),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          duration: 2000,
        ),
        series: <CartesianSeries>[
          ColumnSeries<UserPurchasesStatistics, String>(
            enableTooltip: true,
            name: "User purchases",
            dataSource: statistics,
            xValueMapper: (statistic, _) => statistic.username,
            yValueMapper: (statistic, _) => statistic.totalSpent,
          ),
        ],
      ),
    );
  }

  void _getPurchaseStatistics() {
    var request = StatisticsRequest(
      startDate: _filterValuesProvider.filterValues.startDate,
      endDate: _filterValuesProvider.filterValues.endDate,
    );

    setState(() {
      _purchaseStatisticsFuture =
          _purchaseStatisticsProvider.getPurchaseStatistics(
        request,
        pageSize: _filterValuesProvider.filterValues.limit,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterValuesProvider.addListener(_getPurchaseStatistics);
  }

  @override
  void dispose() {
    _filterValuesProvider.removeListener(_getPurchaseStatistics);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant UserPurchaseStatisticsViewWidget oldWidget) {
    _getPurchaseStatistics();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _purchaseStatisticsProvider =
        context.read<UserPurchaseStatisticsProvider>();
    _filterValuesProvider = context.read<StatisticsFilterValuesProvider>();

    _getPurchaseStatistics();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _purchaseStatisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text(snapshot.error?.toString() ?? "Error"));
        }

        late List<UserPurchasesStatistics> statistics;

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
