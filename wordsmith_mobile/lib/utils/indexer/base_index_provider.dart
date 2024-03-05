import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wordsmith_mobile/utils/indexer/models/ebook_index_model.dart';
import 'package:wordsmith_utils/logger.dart';

abstract class BaseIndexProvider extends ChangeNotifier {
  static final _logger = LogManager.getLogger("EBookIndexer");
  static const String _dbPath = "index.db";

  @protected
  static late Database db;
  @protected
  static const String eBookTable = "books";

  @protected
  Future<String> get localDocumentsPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static void initDatabase() async {
    await databaseFactory.deleteDatabase(_dbPath);
    db = await openDatabase(
      _dbPath,
      onCreate: _onDatabaseCreate,
      version: 1,
    );
    _logger.info("Opened ebook index database");
  }

  static void _onDatabaseCreate(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE $eBookTable (
        ${EbookIndexModel.idColumn} INTEGER PRIMARY KEY,
        ${EbookIndexModel.titleColumn} TEXT,
        ${EbookIndexModel.authorColumn} TEXT,
        ${EbookIndexModel.isReadColumn} INTEGER,
        ${EbookIndexModel.readProgressColumn} TEXT,
        ${EbookIndexModel.encodedImageColumn} TEXT,
        ${EbookIndexModel.updatedDateColumn} INT,
        ${EbookIndexModel.pathColumn} TEXT)''',
    );
  }
}
