import 'package:flutter/material.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';

enum ReportSorts {
  mostRecent,
}

extension ReportSortsExtension on ReportSorts {
  String get apiValue {
    switch (this) {
      case ReportSorts.mostRecent:
        return "ReportDetails.SubmissionDate";
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
  DateTime? startDate;
  DateTime? endDate;
  bool? isClosed;

  ReportFilterValues({
    this.sort = ReportSorts.mostRecent,
    this.sortDirection = SortDirections.descending,
    this.reason,
    this.startDate,
    this.endDate,
    this.isClosed,
  });

  ReportFilterValues copyWith(
      {String? reason,
      DateTime? startDate,
      DateTime? endDate,
      bool? isClosed}) {
    return ReportFilterValues(
      reason: (reason != null || this.reason != null) ? reason : this.reason,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  void clearFilters() {
    reason = null;
    startDate = null;
    endDate = null;
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
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
  }) {
    _filterValues = _filterValues.copyWith(
      isClosed: isClosed,
      startDate: startDate,
      endDate: endDate,
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
