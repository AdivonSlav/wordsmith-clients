import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/entity_result.dart';
import 'package:wordsmith_utils/models/order/order.dart';
import 'package:wordsmith_utils/models/order/order_insert.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class OrderProvider extends BaseProvider<Order> {
  final _logger = LogManager.getLogger("OrderProvider");
  OrderProvider() : super("orders");

  Future<Result<EntityResult<Order>>> createOrder(int ebookId) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var payload = OrderInsert(ebookId);
      var response = await post(
        request: payload,
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(response);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  Future<Result<EntityResult<Order>>> capturePayment(int orderId) async {
    var accessToken = await SecureStore.getValue("access_token");

    try {
      var response = await post(
        additionalRoute: "/$orderId/capture",
        bearerToken: accessToken ?? "",
        retryForRefresh: true,
      );

      return Success(response);
    } on BaseException catch (error) {
      _logger.severe(error);
      return Failure(error);
    }
  }

  @override
  Order fromJson(data) {
    try {
      return Order.fromJson(data);
    } catch (error, stackTrace) {
      _logger.severe(error, stackTrace);
      throw BaseException(
        "Error parsing JSON",
        type: ExceptionType.internalAppError,
      );
    }
  }
}
