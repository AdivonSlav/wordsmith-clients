import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category.dart';

enum LibrarySorts {
  title,
  mostRecent,
  publicationDate,
}

enum LibrarySortDirections {
  ascending,
  descending,
}

extension LibrarySortsExtension on LibrarySorts {
  String get apiValue {
    switch (this) {
      case LibrarySorts.title:
        return "EBook.Title";
      case LibrarySorts.mostRecent:
        return "SyncDate";
      case LibrarySorts.publicationDate:
        return "EBook.PublishedDate";
    }
  }

  String get indexValue {
    switch (this) {
      case LibrarySorts.title:
        return EbookIndexModel.titleColumn;
      case LibrarySorts.mostRecent:
        return ""; // TODO: Implement
      case LibrarySorts.publicationDate:
        return ""; // TODO: Implement
    }
  }

  String get label {
    switch (this) {
      case LibrarySorts.title:
        return "Title";
      case LibrarySorts.mostRecent:
        return "Most recent";
      case LibrarySorts.publicationDate:
        return "Publication date";
    }
  }
}

extension LibrarySortDirectionsExtension on LibrarySortDirections {
  String get apiValue {
    switch (this) {
      case LibrarySortDirections.ascending:
        return "asc";
      case LibrarySortDirections.descending:
        return "desc";
    }
  }

  String get label {
    switch (this) {
      case LibrarySortDirections.ascending:
        return "Ascending";
      case LibrarySortDirections.descending:
        return "Descending";
    }
  }
}

class LibraryFilterValues {
  LibrarySorts sort;
  LibrarySortDirections sortDirection;
  int? selectedMaturityRatingId;
  bool? isRead;
  UserLibraryCategory? selectedCategory;

  LibraryFilterValues({
    required this.sort,
    required this.sortDirection,
    this.selectedMaturityRatingId,
    this.isRead,
  });

  void clearFilters() {
    selectedMaturityRatingId = null;
    isRead = null;
  }
}
