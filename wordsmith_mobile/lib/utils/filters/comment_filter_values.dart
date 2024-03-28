import 'package:wordsmith_utils/models/sorting_directions.dart';

enum CommentSorts {
  mostRecent,
  mostLiked,
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
      case CommentSorts.mostLiked:
        return "LikeCount";
    }
  }

  String get label {
    switch (this) {
      case CommentSorts.mostRecent:
        return "Most recent";
      case CommentSorts.mostLiked:
        return "Most liked";
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
