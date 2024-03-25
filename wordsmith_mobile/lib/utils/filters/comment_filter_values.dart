import 'package:wordsmith_utils/models/sorting_directions.dart';

enum CommentSorts {
  mostRecent,
  mostPopular,
}

enum CommentSortDirections {
  ascending,
  descending,
}

extension CommentSortsExtension on CommentSorts {
  String get apiValue {
    switch (this) {
      case CommentSorts.mostRecent:
        return "DateAdded";
      case CommentSorts.mostPopular:
        return "TODO";
    }
  }

  String get label {
    switch (this) {
      case CommentSorts.mostRecent:
        return "Most recent";
      case CommentSorts.mostPopular:
        return "Most popular";
    }
  }
}

class CommentFilterValues {
  CommentSorts sort;
  SortDirections sortDirection;

  CommentFilterValues({
    required this.sort,
    required this.sortDirection,
  });
}
