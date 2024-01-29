import "dart:convert";
import "package:dio/dio.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/exceptions/forbidden_exception.dart";
import "package:wordsmith_utils/exceptions/unauthorized_exception.dart";
import "package:wordsmith_utils/interceptors/error_interceptor.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:http/http.dart" as http;
import "package:http_parser/http_parser.dart";
import "package:wordsmith_utils/models/transfer_file.dart";
import "package:wordsmith_utils/models/user_login.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

final dio = Dio(
  BaseOptions(
      baseUrl: const String.fromEnvironment("API_URL"),
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      validateStatus: (int? status) {
        return status != null;
      }),
);

abstract class BaseProvider<T> extends AuthProvider {
  static final _logger = LogManager.getLogger("BaseProvider");
  String _endpoint = "";
  static String? _apiUrl;

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _apiUrl = const String.fromEnvironment("API_URL");
  }

  /// Makes an HTTP GET request
  ///
  /// Parameters:
  /// - [filter]: The parameters that should be formatted as query string for the request
  /// - [additionalRoute]: A route to append to the endpoint configured for the provider
  /// - [contentType]: Content type of the request. Defaults to application/json
  /// - [bearerToken]: Bearer token if the request needs to be authorized
  /// - [retryForRefresh]: If set to true and status 401 is the initial response, the provider will attempt to refresh the access token and attempt the request again
  Future<QueryResult<T>> get(
      {String additionalRoute = "",
      dynamic filter,
      String contentType = "",
      String bearerToken = "",
      bool retryForRefresh = false}) async {
    var url = "$_apiUrl$_endpoint$additionalRoute";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw Exception(error);
    }

    var headers =
        createHeaders(contentType: contentType, bearerToken: bearerToken);
    late Response response;

    try {
      response = await dio.getUri(uri, options: Options(headers: headers));
    } on DioException catch (error) {
      if (error.response!.statusCode == 401 && retryForRefresh == true) {
        response = await handleRetry(method: "GET", uri: uri, headers: headers);
      } else {
        var details = getErrorsFromResponse(error.response!);
        throw BaseException(details);
      }
    }

    var queryResult = QueryResult<T>();

    queryResult.page = response.data["page"];
    queryResult.totalCount = response.data["totalCount"];
    queryResult.totalPages = response.data["totalPages"];

    for (var item in response.data["result"]) {
      queryResult.result.add(fromJson(item));
    }

    return queryResult;
  }

  /// Makes an HTTP PUT request
  ///
  /// Parameters:
  /// - [id]: Optional id of the entity being updated
  /// - [request]: The body of the request
  /// - [additionalRoute]: A route to append to the endpoint configured for the provider
  /// - [contentType]: Content type of the request. Defaults to application/json
  /// - [bearerToken]: Bearer token if the request needs to be authorized
  /// - [retryForRefresh]: If set to true and status 401 is the initial response, the provider will attempt to refresh the access token and attempt the request again
  Future<T> put(
      {int? id,
      dynamic request,
      String additionalRoute = "",
      String contentType = "",
      String bearerToken = "",
      bool retryForRefresh = false}) async {
    var url = "$_apiUrl$_endpoint$additionalRoute";
    Uri uri;

    if (id != null) url += "/$id";

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw Exception(error);
    }

    var headers =
        createHeaders(contentType: contentType, bearerToken: bearerToken);
    var jsonRequest = jsonEncode(request);
    // var response = await http.put(uri, body: jsonRequest, headers: headers);
    late Response response;

    try {
      response = await dio.putUri(uri,
          data: jsonRequest, options: Options(headers: headers));
    } on DioException catch (error) {
      if (error.response!.statusCode == 401 && retryForRefresh == true) {
        response = await handleRetry(
            method: "PUT", data: jsonRequest, uri: uri, headers: headers);
      } else {
        var details = getErrorsFromResponse(error.response!);
        throw BaseException(details);
      }
    }

    if (isValidResponse(response)) {
      var data = jsonDecode(response.data);
      return fromJson(data);
    }

    throw Exception("Unknown error");
  }

  /// Makes an HTTP POST request
  ///
  /// Parameters:
  /// - [request]: The body of the request
  /// - [additionalRoute]: A route to append to the endpoint configured for the provider
  /// - [contentType]: Content type of the request. Defaults to application/json
  /// - [bearerToken]: Bearer token if the request needs to be authorized
  /// - [retryForRefresh]: If set to true and status 401 is the initial response, the provider will attempt to refresh the access token and attempt the request again
  Future<T> post(
      {dynamic request,
      String additionalRoute = "",
      String contentType = "",
      String bearerToken = "",
      bool retryForRefresh = false}) async {
    var url = "$_apiUrl$_endpoint$additionalRoute";
    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw Exception(error);
    }

    var headers =
        createHeaders(contentType: contentType, bearerToken: bearerToken);
    var jsonRequest = jsonEncode(request);
    // var response = await http.post(uri, body: jsonRequest, headers: headers);
    late Response response;

    try {
      response = await dio.postUri(uri,
          data: jsonRequest, options: Options(headers: headers));
    } on DioException catch (error) {
      if (error.response!.statusCode == 401 && retryForRefresh == true) {
        response = await handleRetry(
            method: "POST", data: jsonRequest, uri: uri, headers: headers);
      } else {
        var details = getErrorsFromResponse(error.response!);
        throw BaseException(details);
      }
    }

    return fromJson(response.data);
  }

  /// Makes a multipart HTTP POST request
  ///
  /// Parameters:
  /// - [fields]: A map of fields in the multipart request.
  /// - [files]: A map of files in the multipart request.
  /// - [additionalRoute]: A route to append to the endpoint configured for the provider
  /// - [bearerToken]: Bearer token if the request needs to be authorized
  /// - [retryForRefresh]: If set to true and status 401 is the initial response, the provider will attempt to refresh the access token and attempt the request again
  Future<T> postMultipart(
      {Map<String, dynamic>? fields,
      Map<String, TransferFile>? files,
      String additionalRoute = "",
      String bearerToken = "",
      bool retryForRefresh = false}) async {
    var url = "$_apiUrl$_endpoint$additionalRoute";
    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw Exception(error);
    }

    var formData = FormData();

    if (fields != null) {
      fields.forEach((key, value) {
        if (value is String) {
          formData.fields.add(MapEntry(key, value));
        } else if (value is List) {
          for (var listItem in value) {
            formData.files.add(
                MapEntry(key, MultipartFile.fromString(listItem.toString())));
          }
        } else {
          formData.files.add(MapEntry(key, MultipartFile.fromString(value)));
        }
      });
    }

    if (files != null) {
      for (var entry in files.entries) {
        var fieldName = entry.key;
        var transferFile = entry.value;
        MediaType mimeType;

        try {
          mimeType = MediaType.parse(
              transferFile.file.mimeType ?? "application/octet-stream");
        } on FormatException {
          mimeType = MediaType.parse("application/octet-stream");
        }

        var multipartFile = MultipartFile.fromBytes(
            await transferFile.file.readAsBytes(),
            contentType: mimeType);
        formData.files.add(MapEntry(fieldName, multipartFile));
      }
    }

    var headers = {"Authorization": "Bearer $bearerToken"};
    late Response response;

    try {
      response = await dio.postUri(uri,
          data: formData, options: Options(headers: headers));
    } on DioException catch (error) {
      if (error.response!.statusCode == 401 && retryForRefresh == true) {
        response = await handleRetry(
            method: "POST", data: formData.clone(), uri: uri, headers: headers);
      } else {
        var details = getErrorsFromResponse(error.response!);
        throw BaseException(details);
      }
    }

    return fromJson(response.data);
  }

  T fromJson(dynamic data) {
    throw UnimplementedError();
  }

  String getErrorsFromResponse(Response response) {
    String? details;

    if (response.data.isNotEmpty && response.statusCode! >= 299) {
      details = response.data["detail"];

      // Need to parse validation errors
      if (details == null) {
        details = "";
        Map<String, dynamic> validationErrors = response.data['errors'];

        validationErrors.forEach((property, errorMessage) {
          details = details! + errorMessage[0];
          _logger
              .severe("Validation error for property $property: $errorMessage");
        });
      }
    } else {
      details = response.statusMessage!;
    }

    return details!;
  }

  /// Checks what status the Response returned
  ///
  /// If the response is >=299, an exception is thrown depending on the status which should be handled externally
  bool isValidResponse(Response response) {
    String? details;

    if (response.data.isNotEmpty && response.statusCode! >= 299) {
      details = jsonDecode(response.data)["detail"];

      // Need to parse validation errors
      if (details == null) {
        details = "";
        var errorBody = jsonDecode(response.data);
        Map<String, dynamic> validationErrors = errorBody['errors'];

        validationErrors.forEach((property, errorMessage) {
          details = details! + errorMessage[0];
          _logger
              .severe("Validation error for property $property: $errorMessage");
        });
      }
    } else {
      details = response.statusMessage;
    }

    if (response.statusCode! < 299) {
      return true;
    } else if (response.statusCode == 400) {
      throw BaseException("Bad request: $details");
    } else if (response.statusCode == 401) {
      throw UnauthorizedException("$details");
    } else if (response.statusCode == 403) {
      throw ForbiddenException("$details");
    } else {
      _logger.severe(response.data);
      throw BaseException("Something bad happened");
    }
  }

  // /// Checks what status the StreamedResponse returned
  // ///
  // /// If the response is >=299, an exception is thrown depending on the status which should be handled externally
  // Future<String?> isValidStreamedResponse(
  //     ) async {
  //   String? details;

  //   String responseBody = await response.stream.bytesToString();

  //   if (responseBody.isNotEmpty && response.statusCode >= 299) {
  //     details = jsonDecode(responseBody)["detail"];

  //     // Need to parse validation errors
  //     if (details == null) {
  //       details = "";
  //       var errorBody = jsonDecode(responseBody);
  //       Map<String, dynamic> validationErrors = errorBody['errors'];

  //       validationErrors.forEach((property, errorMessage) {
  //         details = details! + errorMessage[0];
  //         _logger
  //             .severe("Validation error for property $property: $errorMessage");
  //       });
  //     }
  //   } else {
  //     details = response.reasonPhrase;
  //   }

  //   if (response.statusCode < 299) {
  //     return responseBody;
  //   } else if (response.statusCode == 400) {
  //     throw BaseException("Bad request: $details");
  //   } else if (response.statusCode == 401) {
  //     throw UnauthorizedException("$details");
  //   } else if (response.statusCode == 403) {
  //     throw ForbiddenException("$details");
  //   } else {
  //     _logger.severe(responseBody);
  //     throw BaseException("Something bad happened");
  //   }
  // }

  /// Attempts to retrieve a new access token using the stored refresh token
  ///
  /// Returns true if new access credentials were stored
  ///
  /// If the token cannot be refreshed, all stored credentials are deleted and the login session is considered terminated
  Future<bool> attemptTokenRefresh() async {
    var refreshToken = await SecureStore.getValue("refresh_token");
    var userRefId = await SecureStore.getValue("user_ref_id");

    if (refreshToken == null || userRefId == null) {
      throw BaseException("No refresh token found!");
    }

    Map<String, String> query = {"id": userRefId};

    var queryString = getQueryString(query);
    var url = Uri.parse("${_apiUrl}users/login/refresh?$queryString");

    try {
      var refreshResponse = await dio.getUri(url,
          options: Options(headers: {"Authorization": refreshToken}));
      var refreshResult = QueryResult<UserLogin>();

      refreshResult.page = refreshResponse.data["page"];
      refreshResult.totalCount = refreshResponse.data["totalCount"];
      refreshResult.totalPages = refreshResponse.data["totalPages"];

      for (var item in refreshResponse.data["result"]) {
        refreshResult.result.add(UserLogin.fromJson(item));
      }

      if (refreshResult.result[0].accessToken != null) {
        await storeLogin(
            loginCreds: refreshResult.result[0], shouldNotify: false);
        return true;
      }
    } on DioException {
      _logger.info("Could not refresh token!");
      await eraseLogin();
      return false;
    } on Exception catch (error) {
      _logger.severe(error);
      await eraseLogin();
      return false;
    }

    return true;
  }

  /// Creates HTTP headers for content type and authorization
  ///
  /// Defaults to application/json if not specified
  Map<String, String> createHeaders(
      {String contentType = "", String bearerToken = ""}) {
    Map<String, String> headers = {};

    if (contentType.isNotEmpty) {
      headers["Content-Type"] = contentType;
    } else {
      headers["Content-Type"] = "application/json";
    }

    if (bearerToken.isNotEmpty) {
      headers["Authorization"] = "Bearer $bearerToken";
    }

    return headers;
  }

  /// Constructs a query string for requests using the passed map
  String getQueryString(Map params,
      {String prefix = "&", bool inRecursion = false}) {
    String query = "";

    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = "[$key]";
        } else if (value is List || value is Map) {
          key = ".$key";
        } else {
          key = ".$key";
        }
      }

      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;

        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }

        query += "$prefix$key=$encoded";
      } else if (value is DateTime) {
        query += "$prefix$key=${(value).toIso8601String()}";
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();

        (value as Map).forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: "$prefix$key", inRecursion: true);
        });
      }
    });

    return query;
  }

  /// Returns a copy of the passed request
  ///
  /// Parameters:
  /// - [request]: The request that should be copied
  http.BaseRequest _copyRequest(http.BaseRequest request) {
    http.BaseRequest requestCopy;

    if (request is http.Request) {
      requestCopy = http.Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
    } else if (request is http.MultipartRequest) {
      requestCopy = http.MultipartRequest(request.method, request.url)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
    } else {
      throw Exception("Request type is unknown for copying!");
    }

    requestCopy
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..headers.addAll(request.headers);

    return requestCopy;
  }

  Future<Response> handleRetry(
      {required Uri uri,
      required String method,
      required Map<String, String> headers,
      dynamic data}) async {
    late Response response;
    var success = await attemptTokenRefresh();

    if (success == true) {
      try {
        var accessToken = await SecureStore.getValue("access_token");

        headers["Authorization"] = accessToken ?? "";
        response = await dio.requestUri(uri,
            data: data, options: Options(headers: headers, method: method));
      } on DioException catch (error) {
        if (error.response!.statusCode == 401) {
          throw UnauthorizedException("Failed despite a token refresh attempt");
        } else {
          throw BaseException(error.message!);
        }
      }
    }

    return response;
  }

  static void configureInterceptors() {
    dio.interceptors.addAll([
      ErrorInterceptor(),
    ]);
  }
}
