class EbookIndexModel {
  int id;
  String title;
  String author;
  bool isRead;
  String readProgress;
  String encodedImage;
  DateTime updatedDate;
  String path;

  static const String _idColumn = "id";
  static const String _titleColumn = "title";
  static const String _authorColumn = "author";
  static const String _isReadColumn = "isRead";
  static const String _readProgressColumn = "readProgress";
  static const String _encodedImageColumn = "encodedImage";
  static const String _updatedDateColumn = "updatedDate";
  static const String _pathColumn = "path";

  static String get idColumn => _idColumn;
  static String get titleColumn => _titleColumn;
  static String get authorColumn => _authorColumn;
  static String get isReadColumn => _isReadColumn;
  static String get readProgressColumn => _readProgressColumn;
  static String get encodedImageColumn => _encodedImageColumn;
  static String get updatedDateColumn => _updatedDateColumn;
  static String get pathColumn => _pathColumn;

  EbookIndexModel({
    required this.id,
    required this.title,
    required this.author,
    required this.isRead,
    required this.readProgress,
    required this.encodedImage,
    required this.updatedDate,
    required this.path,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      _idColumn: id,
      _titleColumn: title,
      _authorColumn: author,
      _isReadColumn: isRead == true ? 1 : 0,
      _readProgressColumn: readProgress,
      _encodedImageColumn: encodedImage,
      _updatedDateColumn: updatedDate.millisecondsSinceEpoch,
      _pathColumn: path
    };

    return map;
  }

  EbookIndexModel.fromMap(Map<String, Object?> map)
      : id = map[_idColumn] as int,
        title = map[_titleColumn] as String,
        author = map[_authorColumn] as String,
        isRead = (map[_isReadColumn] as int) == 1,
        readProgress = map[_readProgressColumn] as String,
        encodedImage = map[_encodedImageColumn] as String,
        updatedDate = DateTime.fromMillisecondsSinceEpoch(
          map[_updatedDateColumn] as int,
          isUtc: true,
        ),
        path = map[_pathColumn] as String;
}
