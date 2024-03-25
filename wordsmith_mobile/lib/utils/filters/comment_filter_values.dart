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
