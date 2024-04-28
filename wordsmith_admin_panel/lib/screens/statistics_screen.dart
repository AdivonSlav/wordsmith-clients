import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_admin_panel/utils/statistics_filter_values.dart';
import 'package:wordsmith_admin_panel/widgets/statistics/user_purchase_statistics_view.dart';
import 'package:wordsmith_admin_panel/widgets/statistics/user_registration_statistics_view.dart';

class StatisticsScreenWidget extends StatefulWidget {
  const StatisticsScreenWidget({super.key});

  @override
  State<StatisticsScreenWidget> createState() => _StatisticsScreenWidgetState();
}

class _StatisticsScreenWidgetState extends State<StatisticsScreenWidget> {
  late StatisticsFilterValuesProvider _filterValuesProvider;

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        FilledButton.icon(
          onPressed: () => _pickDate(),
          icon: const Icon(Icons.date_range),
          label: const Text("Pick timeframe"),
        ),
        const SizedBox(width: 18.0),
        Visibility(
          visible: _shouldShowLimitSelector(),
          child: DropdownButton(
            value: _filterValuesProvider.filterValues.limit,
            items: const [
              DropdownMenuItem(
                value: 5,
                child: Text("Top 3"),
              ),
              DropdownMenuItem(
                value: 10,
                child: Text("Top 10"),
              ),
              DropdownMenuItem(
                value: 20,
                child: Text("Top 20"),
              ),
            ],
            onChanged: (value) => _changeLimit(value),
          ),
        ),
        const Spacer(),
        DropdownButton(
          value: _filterValuesProvider.filterValues.type,
          items: StatisticsTypes.values
              .map<DropdownMenuItem<StatisticsTypes>>((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.label),
            );
          }).toList(),
          onChanged: (value) => _changeStatisticsGraph(value),
        ),
      ],
    );
  }

  Widget _buildGraphView() {
    switch (_filterValuesProvider.filterValues.type) {
      case StatisticsTypes.userRegistrations:
        return const UserRegistrationStatisticsViewWidget();
      case StatisticsTypes.userPurchases:
        return const UserPurchaseStatisticsViewWidget();
      case StatisticsTypes.ebookTraffic:
        return Placeholder();
      case StatisticsTypes.ebookPublishings:
        return Placeholder();
    }
  }

  bool _shouldShowLimitSelector() {
    final type = _filterValuesProvider.filterValues.type;
    return type == StatisticsTypes.userPurchases ||
        type == StatisticsTypes.ebookTraffic;
  }

  void _changeStatisticsGraph(StatisticsTypes? type) {
    if (type == null) return;
    setState(() {
      _filterValuesProvider.updateFilterValueProperties(type: type);
    });
  }

  void _changeLimit(int? limit) {
    if (limit == null) return;
    setState(() {
      _filterValuesProvider.updateFilterValueProperties(limit: limit);
    });
  }

  void _pickDate() async {
    var picked = await showDateRangePicker(
        context: context,
        currentDate: DateTime.now(),
        initialDateRange: DateTimeRange(
          start: _filterValuesProvider.filterValues.startDate,
          end: _filterValuesProvider.filterValues.endDate,
        ),
        firstDate: DateTime(2012),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450.0,
              ),
              child: child,
            ),
          );
        });

    if (picked?.start == null || picked?.end == null) {
      return;
    }

    if (picked?.start == _filterValuesProvider.filterValues.startDate &&
        picked?.end == _filterValuesProvider.filterValues.endDate) {
      return;
    }

    setState(() {
      _filterValuesProvider.updateFilterValueProperties(
        startDate: picked?.start,
        endDate: picked?.end,
      );
    });
  }

  @override
  void initState() {
    _filterValuesProvider = context.read<StatisticsFilterValuesProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(builder: (context) => _buildControls()),
          const Divider(),
          Expanded(
            child: Builder(builder: (context) => _buildGraphView()),
          ),
        ],
      ),
    );
  }
}
