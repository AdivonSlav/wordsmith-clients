import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_mobile/utils/indexers/models/user_index_model.dart';
import 'package:wordsmith_utils/logger.dart';

abstract class BaseIndexProvider extends ChangeNotifier {
  static final _logger = LogManager.getLogger("BaseIndexProvider");
  static const String _dbPath = "index.db";

  @protected
  static late Database db;
  @protected
  static const String eBookTable = "books";
  @protected
  static const String userTable = "user";

  @protected
  Future<String> get localDocumentsPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<void> initDatabase() async {
    // await databaseFactory.deleteDatabase(_dbPath);
    db = await openDatabase(
      _dbPath,
      onCreate: _onDatabaseCreate,
      version: 1,
    );
    _logger.info("Opened index database at $_dbPath");
  }

  static void _onDatabaseCreate(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE $eBookTable (
        ${EbookIndexModel.idColumn} INTEGER PRIMARY KEY,
        ${EbookIndexModel.titleColumn} TEXT,
        ${EbookIndexModel.descriptionColumn} TEXT,
        ${EbookIndexModel.authorColumn} TEXT,
        ${EbookIndexModel.isReadColumn} INTEGER,
        ${EbookIndexModel.readProgressColumn} TEXT,
        ${EbookIndexModel.encodedImageColumn} TEXT,
        ${EbookIndexModel.syncDateColumn} INTEGER,
        ${EbookIndexModel.publishedDateColumn} INTEGER,
        ${EbookIndexModel.updatedDateColumn} INTEGER,
        ${EbookIndexModel.genresColumn} TEXT,
        ${EbookIndexModel.maturityRatingColumn} TEXT,
        ${EbookIndexModel.pathColumn} TEXT)''',
    );

    await db.execute(
      '''CREATE TABLE $userTable (
       ${UserIndexModel.idColumn} INTEGER PRIMARY KEY,
       ${UserIndexModel.usernameColumn} TEXT,
       ${UserIndexModel.emailColumn} TEXT,
       ${UserIndexModel.encodedProfileImageColumn} TEXT,
       ${UserIndexModel.registrationDateColumn} INTEGER)''',
    );
  }
}
