enum SortDirections {
  ascending,
  descending,
}

extension SortDirectionsExtension on SortDirections {
  String get apiValue {
    switch (this) {
      case SortDirections.ascending:
        return "asc";
      case SortDirections.descending:
        return "desc";
    }
  }

  String get label {
    switch (this) {
      case SortDirections.ascending:
        return "Ascending";
      case SortDirections.descending:
        return "Descending";
    }
  }
}
