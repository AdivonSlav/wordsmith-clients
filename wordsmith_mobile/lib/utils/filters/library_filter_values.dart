import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category.dart';

enum LibrarySorts {
  title,
  mostRecent,
  publicationDate,
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

class LibraryFilterValues {
  LibrarySorts sort;
  SortDirections sortDirection;
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
