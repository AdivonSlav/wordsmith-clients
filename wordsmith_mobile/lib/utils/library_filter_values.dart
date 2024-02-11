import 'package:wordsmith_utils/models/maturity_rating/maturity_rating.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category.dart';

class LibraryFilterValues {
  final List<MaturityRating> maturityRatings;
  String sortByProperty;
  String sortByDirection;
  int? selectedMaturityRating;
  bool? isRead;
  UserLibraryCategory? selectedCategory;

  LibraryFilterValues({
    required this.maturityRatings,
    required this.sortByProperty,
    required this.sortByDirection,
    this.selectedMaturityRating,
    this.isRead,
  });

  void clearFilters() {
    selectedMaturityRating = null;
    isRead = null;
  }
}
