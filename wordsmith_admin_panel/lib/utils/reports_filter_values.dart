import 'package:flutter/material.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';

enum ReportSorts {
  mostRecent,
}

extension ReportSortsExtension on ReportSorts {
  String get apiValue {
    switch (this) {
      case ReportSorts.mostRecent:
        return "ReportDate";
    }
  }

  String get label {
    switch (this) {
      case ReportSorts.mostRecent:
        return "Most recent";
    }
  }
}

class ReportFilterValues {
  ReportSorts sort;
  SortDirections sortDirection;
  String? reason;
  DateTime? reportDate;
  bool? isClosed;

  ReportFilterValues({
    this.sort = ReportSorts.mostRecent,
    this.sortDirection = SortDirections.descending,
    this.reason,
    this.reportDate,
    this.isClosed,
  });

  ReportFilterValues copyWith(
      {String? reason, DateTime? reportDate, bool? isClosed}) {
    return ReportFilterValues(
      reason: reason ?? this.reason,
      reportDate: reportDate ?? this.reportDate,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  void clearFilters() {
    reason = null;
    reportDate = null;
    isClosed = null;
  }
}

class ReportFilterValuesProvider extends ChangeNotifier {
  ReportFilterValues _filterValues = ReportFilterValues();

  ReportFilterValuesProvider();

  ReportFilterValues get filterValues => _filterValues;

  void updateFilterValues(ReportFilterValues newFilterValues) {
    _filterValues = newFilterValues;
    notifyListeners();
  }

  void updateFilterValueProperties({
    bool? isClosed,
    DateTime? reportDate,
    String? reason,
  }) {
    _filterValues = _filterValues.copyWith(
      isClosed: isClosed,
      reportDate: reportDate,
      reason: reason,
    );

    notifyListeners();
  }

  void clearFilterValues({bool notify = true}) {
    _filterValues.clearFilters();

    if (notify) {
      notifyListeners();
    }
  }
}
