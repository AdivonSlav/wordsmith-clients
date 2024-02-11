import 'package:wordsmith_utils/models/user_library_category/user_library_category.dart';

class LibraryFilterValues {
  String sortByProperty;
  String sortByDirection;
  int? selectedMaturityRatingId;
  bool? isRead;
  UserLibraryCategory? selectedCategory;

  LibraryFilterValues({
    required this.sortByProperty,
    required this.sortByDirection,
    this.selectedMaturityRatingId,
    this.isRead,
  });

  void clearFilters() {
    selectedMaturityRatingId = null;
    isRead = null;
  }
}
