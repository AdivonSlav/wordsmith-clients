import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category.dart';

enum LibrarySorts {
  title,
  syncDate,
  publicationDate,
}

extension LibrarySortsExtension on LibrarySorts {
  String get apiValue {
    switch (this) {
      case LibrarySorts.title:
        return "EBook.Title";
      case LibrarySorts.syncDate:
        return "SyncDate";
      case LibrarySorts.publicationDate:
        return "EBook.PublishedDate";
    }
  }

  String get indexValue {
    switch (this) {
      case LibrarySorts.title:
        return EbookIndexModel.titleColumn;
      case LibrarySorts.syncDate:
        return EbookIndexModel.syncDateColumn;
      case LibrarySorts.publicationDate:
        return EbookIndexModel.publishedDateColumn;
    }
  }

  String get label {
    switch (this) {
      case LibrarySorts.title:
        return "Title";
      case LibrarySorts.syncDate:
        return "Sync date";
      case LibrarySorts.publicationDate:
        return "Publication date";
    }
  }
}

class LibraryFilterValues {
  LibrarySorts sort;
  SortDirections sortDirection;
  int? selectedMaturityRatingId;
  bool? isRead;
  UserLibraryCategory? selectedCategory;

  LibraryFilterValues({
    this.sort = LibrarySorts.title,
    this.sortDirection = SortDirections.ascending,
    this.selectedMaturityRatingId,
    this.isRead,
    this.selectedCategory,
  });

  LibraryFilterValues copyWith({
    LibrarySorts sort = LibrarySorts.title,
    SortDirections sortDirection = SortDirections.ascending,
    int? selectedMaturityRatingId,
    bool? isRead,
    UserLibraryCategory? selectedCategory,
  }) {
    return LibraryFilterValues(
      sort: sort,
      sortDirection: sortDirection,
      selectedMaturityRatingId:
          selectedMaturityRatingId ?? this.selectedMaturityRatingId,
      isRead: isRead ?? this.isRead,
      selectedCategory: selectedCategory,
    );
  }

  void clearFilters() {
    sort = LibrarySorts.title;
    sortDirection = SortDirections.ascending;
    selectedMaturityRatingId = null;
    isRead = null;
    selectedCategory = null;
  }
}

class LibraryFilterValuesProvider extends ChangeNotifier {
  LibraryFilterValues _filterValues = LibraryFilterValues();

  LibraryFilterValuesProvider();

  LibraryFilterValues get filterValues => _filterValues;

  void updateFilterValues(LibraryFilterValues newFilterValues) {
    _filterValues = newFilterValues;
    notifyListeners();
  }

  void updateFilterValueProperties({
    LibrarySorts? sort,
    SortDirections? sortDirection,
    int? selectedMaturityRatingId,
    bool? isRead,
    UserLibraryCategory? selectedCategory,
  }) {
    _filterValues = _filterValues.copyWith(
      sort: sort ?? _filterValues.sort,
      sortDirection: sortDirection ?? _filterValues.sortDirection,
      selectedMaturityRatingId: selectedMaturityRatingId,
      isRead: isRead,
      selectedCategory: selectedCategory,
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
