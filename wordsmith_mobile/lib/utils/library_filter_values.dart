import 'package:wordsmith_utils/models/maturity_rating.dart';

class LibraryFilterValues {
  final List<MaturityRating> maturityRatings;
  int? selectedMaturityRating;
  bool? isRead;

  LibraryFilterValues({
    this.selectedMaturityRating,
    this.isRead,
    required this.maturityRatings,
  });

  void clearFilters() {
    selectedMaturityRating = null;
    isRead = null;
  }
}
