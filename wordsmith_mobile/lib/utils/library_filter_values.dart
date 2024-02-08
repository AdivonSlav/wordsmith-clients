import 'package:wordsmith_utils/models/maturity_rating.dart';

class LibraryFilterValues {
  final List<MaturityRating> maturityRatings;
  String sortByProperty;
  String sortByDirection;
  int? selectedMaturityRating;
  bool? isRead;

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
