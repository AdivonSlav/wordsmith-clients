import 'package:flutter/material.dart';

class StatisticsFilterValues {
  DateTime startDate;
  DateTime endDate;

  StatisticsFilterValues({
    required this.startDate,
    required this.endDate,
  });
}

class StatisticsFilterValuesProvider extends ChangeNotifier {
  StatisticsFilterValues _filterValues;

  StatisticsFilterValuesProvider()
      : _filterValues = StatisticsFilterValues(
          startDate: DateTime.now().subtract(const Duration(days: 365)),
          endDate: DateTime.now(),
        );

  StatisticsFilterValues get filterValues => _filterValues;

  void updateFilterValues(StatisticsFilterValues newFilterValues) {
    _filterValues = newFilterValues;
    notifyListeners();
  }
}
