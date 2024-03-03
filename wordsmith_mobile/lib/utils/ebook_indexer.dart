import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';

const String _eBookTable = "books";
const String _idColumn = "id";
const String _titleColumn = "title";
const String _authorColumn = "author";
const String _isReadColumn = "isRead";
const String _readProgressColumn = "readProgress";
const String _encodedImageColumn = "encodedImage";
const String _modifiedDateColumn = "modifiedDate";
const String _pathColumn = "path";

class EBookIndexModel {
  int? id;
  String? title;
  String? author;
  bool? isRead;
  String? readProgress;
  String? encodedImage;
  DateTime? modifiedDate;
  String? path;

  EBookIndexModel({
    required this.id,
    required this.title,
    required this.author,
    required this.isRead,
    required this.readProgress,
    required this.encodedImage,
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
      _modifiedDateColumn: modifiedDate?.millisecondsSinceEpoch,
      _pathColumn: path
    };

    return map;
  }

  EBookIndexModel.fromMap(Map<String, Object?> map) {
    id = map[_idColumn] as int;
    title = map[_titleColumn] as String;
    author = map[_authorColumn] as String;
    isRead = (map[_isReadColumn] as int) == 1;
    readProgress = map[_readProgressColumn] as String;
    encodedImage = map[_encodedImageColumn] as String;
    modifiedDate = DateTime.fromMillisecondsSinceEpoch(
      map[_modifiedDateColumn] as int,
      isUtc: true,
    );
    path = map[_pathColumn] as String;
  }
}

abstract class EBookIndexer {
  static final _logger = LogManager.getLogger("EBookIndexer");
  static late Database _db;

  static Future<String> get _localDocumentsPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static void initDatabase() async {
    _db = await openDatabase(
      "index.db",
      onCreate: _onDatabaseCreate,
      version: 1,
    );
    _logger.info("Opened ebook index database");
  }

  static Future<Result<String>> addToIndex(
      UserLibrary libraryEntry, TransferFile transferFile) async {
    var pathToBook = await _writeBook(transferFile);

    switch (pathToBook) {
      case Success(data: final path):
        var model = EBookIndexModel(
          id: libraryEntry.eBookId,
          title: libraryEntry.eBook.title,
          author: libraryEntry.eBook.author.username,
          isRead: libraryEntry.isRead,
          readProgress: libraryEntry.readProgress,
          encodedImage: libraryEntry.eBook.coverArt.encodedImage,
          path: path,
        );

        await _db.insert(_eBookTable, model.toMap());

        return Success(path);
      case Failure(exception: final e):
        return Failure(e);
    }
  }

  static Future<bool> removeFromIndex(int eBookId) async {
    return true;
  }

  static Future<Result<EBookIndexModel?>> getById(int id) async {
    try {
      var records = await _db.query(_eBookTable, where: "$_idColumn = $id");

      if (records.isEmpty) return const Success(null);

      return Success(EBookIndexModel.fromMap(records[0]));
    } on Exception catch (error) {
      _logger.severe(error, StackTrace.current);
      return Failure(BaseException("Could not fetch downloaded ebook!",
          type: ExceptionType.internalAppError));
    }
  }

  static Future<Result<List<EBookIndexModel>>> getAll() async {
    List<EBookIndexModel> models = [];
    List<Map<String, Object?>> records = [];

    try {
      records = await _db.query(_eBookTable);

      for (var record in records) {
        models.add(EBookIndexModel.fromMap(record));
      }

      return Success(models);
    } on Exception catch (error) {
      _logger.severe(error, StackTrace.current);
      return Failure(BaseException("Could not fetch downloaded ebooks!",
          type: ExceptionType.internalAppError));
    }
  }

  static void _onDatabaseCreate(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE $_eBookTable (
        $_idColumn INTEGER PRIMARY KEY,
        $_titleColumn TEXT,
        $_authorColumn TEXT,
        $_isReadColumn INTEGER,
        $_readProgressColumn TEXT,
        $_encodedImageColumn TEXT,
        $_modifiedDateColumn INT,
        $_pathColumn TEXT)''',
    );
  }

  static Future<Result<String>> _writeBook(TransferFile transferFile) async {
    late String docPath;

    try {
      docPath = await _localDocumentsPath;
    } on MissingPlatformDirectoryException catch (error) {
      _logger.severe(error, StackTrace.current);
      return Failure(BaseException("Could not save ebook!",
          type: ExceptionType.internalAppError));
    }

    final savePath = "$docPath/${transferFile.name}.epub";
    await transferFile.file.saveTo(savePath);

    return Success(savePath);
  }
}
