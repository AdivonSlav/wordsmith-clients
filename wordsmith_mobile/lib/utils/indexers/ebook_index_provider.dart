import 'package:path_provider/path_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/base_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';

class EbookIndexProvider extends BaseIndexProvider {
  final _logger = LogManager.getLogger("EBookIndexer");

  Future<Result<EbookIndexModel>> addToIndex(
      UserLibrary libraryEntry, TransferFile transferFile) async {
    if (libraryEntry.eBook.coverArt.encodedImage == null) {
      return Failure(BaseException("Cover art for the ebook was not found!",
          type: ExceptionType.internalAppError));
    }

    var pathToBook = await _writeBook(transferFile);

    switch (pathToBook) {
      case Success(data: final path):
        try {
          var model = EbookIndexModel(
            id: libraryEntry.eBookId,
            title: libraryEntry.eBook.title,
            author: libraryEntry.eBook.author.username,
            isRead: libraryEntry.isRead,
            readProgress: libraryEntry.readProgress,
            encodedImage: libraryEntry.eBook.coverArt.encodedImage!,
            updatedDate: libraryEntry.eBook.updatedDate,
            path: path,
          );

          await BaseIndexProvider.db.insert(
            BaseIndexProvider.eBookTable,
            model.toMap(),
          );

          return Success(model);
        } catch (error, stackTrace) {
          _logger.severe("Could not index ebook!", error, stackTrace);
          return Failure(BaseException(error.toString(),
              type: ExceptionType.internalAppError));
        }
      case Failure(exception: final e):
        return Failure(e);
    }
  }

  Future<bool> removeFromIndex(int eBookId) async {
    return true;
  }

  Future<Result<EbookIndexModel?>> getById(int id) async {
    try {
      var records = await BaseIndexProvider.db.query(
        BaseIndexProvider.eBookTable,
        where: "${EbookIndexModel.idColumn} = $id",
      );

      if (records.isEmpty) return const Success(null);

      var model = EbookIndexModel.fromMap(records[0]);

      return Success(model);
    } catch (error, stackTrace) {
      _logger.severe("Error getting results from index!", error, stackTrace);
      return Failure(BaseException("Could not fetch downloaded ebook!",
          type: ExceptionType.internalAppError));
    }
  }

  Future<Result<List<EbookIndexModel>>> getAll() async {
    List<EbookIndexModel> models = [];
    List<Map<String, Object?>> records = [];

    try {
      records = await BaseIndexProvider.db.query(BaseIndexProvider.eBookTable);

      for (var record in records) {
        models.add(EbookIndexModel.fromMap(record));
      }

      return Success(models);
    } catch (error, stackTrace) {
      _logger.severe("Error getting results from index!", error, stackTrace);
      return Failure(BaseException("Could not fetch downloaded ebooks!",
          type: ExceptionType.internalAppError));
    }
  }

  Future<Result<String>> _writeBook(TransferFile transferFile) async {
    late String docPath;

    try {
      docPath = await localDocumentsPath;
    } on MissingPlatformDirectoryException catch (error, stackTrace) {
      _logger.severe("Could not save ebook!", error, stackTrace);
      return Failure(BaseException("Could not save ebook!",
          type: ExceptionType.internalAppError));
    }

    final savePath = "$docPath/${transferFile.name}";

    try {
      await transferFile.file.saveTo(savePath);
    } catch (error, stackTrace) {
      _logger.severe("Could not save ebook!", error, stackTrace);
      return Failure(BaseException("Could not save",
          type: ExceptionType.internalAppError));
    }

    return Success(savePath);
  }
}
