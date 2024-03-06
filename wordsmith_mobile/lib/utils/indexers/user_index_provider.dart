import 'package:wordsmith_mobile/utils/indexers/base_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/models/user_index_model.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';

class UserIndexProvider extends BaseIndexProvider {
  final _logger = LogManager.getLogger("UserIndexer");

  Future<Result<UserIndexModel>> addToIndex(User user) async {
    try {
      var existingModel = await getUser();

      switch (existingModel) {
        case Success<UserIndexModel?>():
          if (existingModel.data != null) {
            _logger.info(
                "User ${user.username} already indexed, returning the existing record...");
            return Success(existingModel.data!);
          }
        case Failure<UserIndexModel?>():
          return Failure(existingModel.exception);
      }

      var model = UserIndexModel(
        id: user.id,
        username: user.username,
        email: user.email,
        encodedProfileImage: "",
        registrationDate: user.registrationDate,
      );

      await BaseIndexProvider.db
          .insert(BaseIndexProvider.userTable, model.toMap());

      _logger.info("User ${user.username} succesfully indexed");
      return Success(model);
    } catch (error, stackTrace) {
      _logger.severe("Could not index user!", error, stackTrace);
      return Failure(BaseException(error.toString(),
          type: ExceptionType.internalAppError));
    }
  }

  Future<Result<String>> removeFromIndex() async {
    try {
      // Table will only ever contain one row so deleting all is fine
      await BaseIndexProvider.db.delete(
        BaseIndexProvider.userTable,
        where: null,
      );

      _logger.info("Deleted user from index!");
      return const Success("Succesfully deleted user from index");
    } catch (error, stackTrace) {
      _logger.severe("Could not delete user from index!", error, stackTrace);
      return Failure(BaseException("Could not delete user from index!",
          type: ExceptionType.internalAppError));
    }
  }

  Future<Result<UserIndexModel?>> getUser() async {
    try {
      // Table will only ever contain one row
      var records =
          await BaseIndexProvider.db.query(BaseIndexProvider.userTable);

      if (records.isEmpty) {
        return const Success(null);
      }

      var model = UserIndexModel.fromMap(records[0]);

      return Success(model);
    } catch (error, stackTrace) {
      _logger.severe("Error getting results from index!", error, stackTrace);
      return Failure(BaseException(error.toString(),
          type: ExceptionType.internalAppError));
    }
  }
}
