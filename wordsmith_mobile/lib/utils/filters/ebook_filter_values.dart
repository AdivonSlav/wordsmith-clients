import 'package:flutter/material.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';

enum EbookSorts {
  title,
  publicationDate,
  syncCount;
}

extension EbookSortsExtension on EbookSorts {
  String get apiValue {
    switch (this) {
      case EbookSorts.title:
        return "Title";
      case EbookSorts.publicationDate:
        return "PublishedDate";
      case EbookSorts.syncCount:
        return "SyncCount";
    }
  }

  String get label {
    switch (this) {
      case EbookSorts.title:
        return "Title";
      case EbookSorts.publicationDate:
        return "Publication date";
      case EbookSorts.syncCount:
        return "Sync count";
    }
  }
}

class EbookFilterValues {
  EbookSorts sort;
  SortDirections sortDirection;
  int? selectedMaturityRatingId;
  int? selectedGenreId;

  EbookFilterValues({
    this.sort = EbookSorts.title,
    this.sortDirection = SortDirections.ascending,
    this.selectedMaturityRatingId,
    this.selectedGenreId,
  });

  EbookFilterValues copyWith({
    EbookSorts sort = EbookSorts.title,
    SortDirections sortDirection = SortDirections.ascending,
    int? selectedMaturityRatingId,
    int? selectedGenreId,
  }) {
    return EbookFilterValues(
      sort: sort,
      sortDirection: sortDirection,
      selectedMaturityRatingId:
          selectedMaturityRatingId ?? this.selectedMaturityRatingId,
      selectedGenreId: selectedGenreId ?? this.selectedGenreId,
    );
  }

  void clearFilters() {
    sort = EbookSorts.title;
    sortDirection = SortDirections.ascending;
    selectedMaturityRatingId = null;
    selectedGenreId = null;
  }
}

class EbookFilterValuesProvider extends ChangeNotifier {
  EbookFilterValues _filterValues = EbookFilterValues();

  EbookFilterValuesProvider();

  EbookFilterValues get filterValues => _filterValues;

  void updateFilterValues(EbookFilterValues newFilterValues) {
    _filterValues = newFilterValues;
    notifyListeners();
  }

  void updateFilterValueProperties({
    EbookSorts? sort,
    SortDirections? sortDirection,
    int? selectedMaturityRatingId,
    int? selectedGenreId,
  }) {
    _filterValues = _filterValues.copyWith(
      sort: sort ?? _filterValues.sort,
      sortDirection: sortDirection ?? _filterValues.sortDirection,
      selectedMaturityRatingId: selectedMaturityRatingId,
      selectedGenreId: selectedGenreId,
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
