class EbookIndexModel {
  int id;
  String title;
  String description;
  String author;
  bool isRead;
  String readProgress;
  String encodedImage;
  DateTime syncDate;
  DateTime publishedDate;
  DateTime updatedDate;
  String genres;
  String maturityRating;
  String path;

  static const String idColumn = "id";
  static const String titleColumn = "title";
  static const String descriptionColumn = "description";
  static const String authorColumn = "author";
  static const String isReadColumn = "is_read";
  static const String readProgressColumn = "read_progress";
  static const String encodedImageColumn = "encoded_image";
  static const String syncDateColumn = "sync_date";
  static const String publishedDateColumn = "published_date";
  static const String updatedDateColumn = "updated_date";
  static const String genresColumn = "genres";
  static const String maturityRatingColumn = "maturity_rating";
  static const String pathColumn = "path";

  EbookIndexModel({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.isRead,
    required this.readProgress,
    required this.encodedImage,
    required this.syncDate,
    required this.publishedDate,
    required this.updatedDate,
    required this.genres,
    required this.maturityRating,
    required this.path,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      idColumn: id,
      titleColumn: title,
      descriptionColumn: description,
      authorColumn: author,
      isReadColumn: isRead == true ? 1 : 0,
      readProgressColumn: readProgress,
      encodedImageColumn: encodedImage,
      syncDateColumn: syncDate.millisecondsSinceEpoch,
      publishedDateColumn: publishedDate.millisecondsSinceEpoch,
      updatedDateColumn: updatedDate.millisecondsSinceEpoch,
      genresColumn: genres,
      maturityRatingColumn: maturityRating,
      pathColumn: path
    };

    return map;
  }

  EbookIndexModel.fromMap(Map<String, Object?> map)
      : id = map[idColumn] as int,
        title = map[titleColumn] as String,
        description = map[descriptionColumn] as String,
        author = map[authorColumn] as String,
        isRead = (map[isReadColumn] as int) == 1,
        readProgress = map[readProgressColumn] as String,
        encodedImage = map[encodedImageColumn] as String,
        syncDate = DateTime.fromMillisecondsSinceEpoch(
          map[syncDateColumn] as int,
        ),
        publishedDate = DateTime.fromMillisecondsSinceEpoch(
          map[publishedDateColumn] as int,
        ),
        updatedDate = DateTime.fromMillisecondsSinceEpoch(
          map[updatedDateColumn] as int,
        ),
        genres = map[genresColumn] as String,
        maturityRating = map[maturityRatingColumn] as String,
        path = map[pathColumn] as String;
}
