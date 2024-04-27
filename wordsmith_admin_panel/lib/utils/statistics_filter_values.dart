import 'package:flutter/material.dart';

enum StatisticsTypes {
  userRegistrations,
  userPurchases,
  ebookTraffic,
  ebookPublishings
}

extension StatisticsTypesExtension on StatisticsTypes {
  String get label {
    switch (this) {
      case StatisticsTypes.userRegistrations:
        return "User registrations";
      case StatisticsTypes.userPurchases:
        return "User purchases";
      case StatisticsTypes.ebookTraffic:
        return "Traffic by ebook";
      case StatisticsTypes.ebookPublishings:
        return "Ebook publishings";
    }
  }
}

class StatisticsFilterValues {
  StatisticsTypes type;
  DateTime startDate;
  DateTime endDate;
  int limit;

  StatisticsFilterValues({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.limit,
  });

  StatisticsFilterValues copyWith({
    StatisticsTypes? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    return StatisticsFilterValues(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      limit: limit ?? this.limit,
    );
  }
}

class StatisticsFilterValuesProvider extends ChangeNotifier {
  StatisticsFilterValues _filterValues;

  StatisticsFilterValuesProvider()
      : _filterValues = StatisticsFilterValues(
          type: StatisticsTypes.userRegistrations,
          startDate: DateTime.now().subtract(const Duration(days: 365)),
          endDate: DateTime.now(),
          limit: 10,
        );

  StatisticsFilterValues get filterValues => _filterValues;

  void updateFilterValueProperties({
    StatisticsTypes? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    _filterValues = _filterValues.copyWith(
      type: type,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );

    notifyListeners();
  }

  void updateFilterValues(StatisticsFilterValues newFilterValues) {
    _filterValues = newFilterValues;
    notifyListeners();
  }
}
