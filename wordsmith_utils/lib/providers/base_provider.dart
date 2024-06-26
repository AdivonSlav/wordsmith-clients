import "dart:convert";
import "dart:io";
import "package:file_selector/file_selector.dart";
import "package:flutter/foundation.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/exceptions/exception_types.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/entity_result.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:http/http.dart" as http;
import "package:http_parser/http_parser.dart";
import "package:wordsmith_utils/models/transfer_file.dart";
import "package:wordsmith_utils/models/user/user_login.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

abstract class BaseProvider<T> extends AuthProvider {
  String _endpoint = "";

  static late String apiUrl;
  static final _logger = LogManager.getLogger("BaseProvider");

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
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
    var url = "$apiUrl$_endpoint$additionalRoute";

    if (filter != null) {
      var queryString = _getQueryString(filter);
      url = "$url?$queryString";
    }

    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw BaseException("Something bad happened");
    }

    var headers =
        _createHeaders(contentType: contentType, bearerToken: bearerToken);
    late http.Response response;

    try {
      response = await http.get(uri, headers: headers);
    } catch (error, stackTrace) {
      _handleInternalAppError(error, stackTrace);
    }

    // If retrying is enabled and status 401 is returned, attempt to refresh the access token and send the request again
    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        headers =
            _createHeaders(contentType: contentType, bearerToken: bearerToken);
        late http.Response refreshedResponse;

        try {
          refreshedResponse = await http.get(uri, headers: headers);
        } catch (error, stackTrace) {
          _handleInternalAppError(error, stackTrace);
        }

        return await _handleGetResponse(refreshedResponse);
      } else {
        throw BaseException("Session timed out",
            type: ExceptionType.unauthorizedException);
      }
    }

    return await _handleGetResponse(response);
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
  Future<EntityResult<T>> put(
      {int? id,
      dynamic request,
      String additionalRoute = "",
      String contentType = "",
      String bearerToken = "",
      bool retryForRefresh = false}) async {
    var url = "$apiUrl$_endpoint$additionalRoute";
    Uri uri;

    if (id != null) url += "/$id";

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw BaseException("Something bad happened");
    }

    var headers =
        _createHeaders(contentType: contentType, bearerToken: bearerToken);
    var jsonRequest = jsonEncode(request);
    late http.Response response;

    try {
      response = await http.put(uri, body: jsonRequest, headers: headers);
    } catch (error, stackTrace) {
      _handleInternalAppError(error, stackTrace);
    }

    // If retrying is enabled and status 401 is returned, attempt to refresh the access token and send the request again
    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        headers =
            _createHeaders(contentType: contentType, bearerToken: bearerToken);
        late http.Response refreshedResponse;

        try {
          refreshedResponse =
              await http.put(uri, body: jsonRequest, headers: headers);
        } catch (error, stackTrace) {
          _handleInternalAppError(error, stackTrace);
        }

        return await _handleResponse(refreshedResponse);
      } else {
        throw BaseException("Session timed out",
            type: ExceptionType.unauthorizedException);
      }
    }

    return await _handleResponse(response);
  }

  /// Makes an HTTP POST request
  ///
  /// Parameters:
  /// - [request]: The body of the request
  /// - [additionalRoute]: A route to append to the endpoint configured for the provider
  /// - [contentType]: Content type of the request. Defaults to application/json
  /// - [bearerToken]: Bearer token if the request needs to be authorized
  /// - [retryForRefresh]: If set to true and status 401 is the initial response, the provider will attempt to refresh the access token and attempt the request again
  Future<EntityResult<T>> post(
      {dynamic request,
      String additionalRoute = "",
      String contentType = "",
      String bearerToken = "",
      bool retryForRefresh = false}) async {
    var url = "$apiUrl$_endpoint$additionalRoute";
    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw BaseException("Something bad happened");
    }

    var headers =
        _createHeaders(contentType: contentType, bearerToken: bearerToken);
    var jsonRequest = jsonEncode(request);
    late http.Response response;

    try {
      response = await http.post(uri, body: jsonRequest, headers: headers);
    } catch (error, stackTrace) {
      _handleInternalAppError(error, stackTrace);
    }
    // If retrying is enabled and status 401 is returned, attempt to refresh the access token and send the request again
    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        headers =
            _createHeaders(contentType: contentType, bearerToken: bearerToken);
        late http.Response refreshedResponse;

        try {
          refreshedResponse =
              await http.post(uri, body: jsonRequest, headers: headers);
        } catch (error, stackTrace) {
          _handleInternalAppError(error, stackTrace);
        }

        return await _handleResponse(refreshedResponse);
      } else {
        throw BaseException("Session timed out",
            type: ExceptionType.unauthorizedException);
      }
    }

    return await _handleResponse(response);
  }

  /// Makes a multipart HTTP POST request
  ///
  /// Parameters:
  /// - [fields]: A map of fields in the multipart request.
  /// - [files]: A map of files in the multipart request.
  /// - [additionalRoute]: A route to append to the endpoint configured for the provider
  /// - [bearerToken]: Bearer token if the request needs to be authorized
  /// - [retryForRefresh]: If set to true and status 401 is the initial response, the provider will attempt to refresh the access token and attempt the request again
  Future<EntityResult<T>> postMultipart(
      {Map<String, dynamic>? fields,
      Map<String, TransferFile>? files,
      String additionalRoute = "",
      String bearerToken = "",
      bool retryForRefresh = false}) async {
    var url = "$apiUrl$_endpoint$additionalRoute";
    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw BaseException("Something bad happened");
    }

    var request = http.MultipartRequest('POST', uri);

    request =
        _setMultipartPayload(request: request, fields: fields, files: files);

    if (bearerToken.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $bearerToken";
    }

    late http.StreamedResponse response;

    try {
      response = await request.send();
    } catch (error, stackTrace) {
      _handleInternalAppError(error, stackTrace);
    }

    // If retrying is enabled and status 401 is returned, attempt to refresh the access token and send the request again
    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        http.MultipartRequest? retryRequest =
            _copyRequest(request) as http.MultipartRequest;
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        retryRequest.headers["Authorization"] = "Bearer $bearerToken";
        retryRequest = _setMultipartPayload(
            request: retryRequest, fields: fields, files: files);
        late http.StreamedResponse retryResponse;

        try {
          retryResponse = await retryRequest.send();
        } catch (error, stackTrace) {
          _handleInternalAppError(error, stackTrace);
        }

        return await _handleMultipartResponse(retryResponse);
      } else {
        throw BaseException("Session timed out",
            type: ExceptionType.unauthorizedException);
      }
    }

    return await _handleMultipartResponse(response);
  }

  /// Makes an HTTP DELETE request
  ///
  /// Parameters:
  /// - [id]: ID of the entity being deleted
  /// - [additionalRoute]: A route to append to the endpoint configured for the provider
  /// - [contentType]: Content type of the request. Defaults to application/json
  /// - [bearerToken]: Bearer token if the request needs to be authorized
  /// - [retryForRefresh]: If set to true and status 401 is the initial response, the provider will attempt to refresh the access token and attempt the request again
  Future<EntityResult<T>> delete(
      {int? id,
      String additionalRoute = "",
      String contentType = "",
      String bearerToken = "",
      bool retryForRefresh = false}) async {
    var url = "$apiUrl$_endpoint$additionalRoute";

    if (id != null) url += "/$id";

    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw BaseException("Something bad happened");
    }

    var headers =
        _createHeaders(contentType: contentType, bearerToken: bearerToken);
    late http.Response response;

    try {
      response = await http.delete(uri, headers: headers);
    } catch (error, stackTrace) {
      _handleInternalAppError(error, stackTrace);
    }

    // If retrying is enabled and status 401 is returned, attempt to refresh the access token and send the request again
    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        headers =
            _createHeaders(contentType: contentType, bearerToken: bearerToken);
        late http.Response refreshedResponse;

        try {
          refreshedResponse = await http.delete(uri, headers: headers);
        } catch (error, stackTrace) {
          _handleInternalAppError(error, stackTrace);
        }

        return await _handleResponse(refreshedResponse);
      } else {
        throw BaseException("Session timed out",
            type: ExceptionType.unauthorizedException);
      }
    }

    return await _handleResponse(response);
  }

  Future<TransferFile> getBytes(
      {String endpoint = "",
      String additionalRoute = "",
      String contentType = "",
      String bearerToken = "",
      bool retryForRefresh = true}) async {
    var url = apiUrl;

    if (endpoint.isNotEmpty) {
      url += endpoint;
    } else {
      url += _endpoint;
    }

    url += additionalRoute;

    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (error) {
      _logger.severe("Invalid URL: $url");
      throw BaseException("Something bad happened");
    }

    var headers = {"Authorization": "Bearer $bearerToken"};
    late http.Response response;

    try {
      response = await http.get(uri, headers: headers);
    } catch (error, stackTrace) {
      _handleInternalAppError(error, stackTrace);
    }

    // If retrying is enabled and status 401 is returned, attempt to refresh the access token and send the request again
    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        headers = {"Authorization": "Bearer $bearerToken"};
        late http.Response refreshedResponse;

        try {
          refreshedResponse = await http.get(uri, headers: headers);
        } catch (error, stackTrace) {
          _handleInternalAppError(error, stackTrace);
        }

        return await _handleByteResponse(refreshedResponse);
      } else {
        throw BaseException("Session timed out",
            type: ExceptionType.unauthorizedException);
      }
    }

    return await _handleByteResponse(response);
  }

  T fromJson(dynamic data) {
    throw BaseException("Unimplemented fromJson method!",
        type: ExceptionType.internalAppError);
  }

  /// Checks what status the Response returned
  ///
  /// If the response is >=299, an exception is thrown depending on the status which should be handled externally
  bool _isValidResponse(http.Response response) {
    String? details;

    if (response.body.isNotEmpty && response.statusCode >= 299) {
      details = jsonDecode(response.body)["detail"];

      // Need to parse validation errors
      if (details == null) {
        details = "";
        var errorBody = jsonDecode(response.body);
        Map<String, dynamic> validationErrors = errorBody['errors'];

        validationErrors.forEach((property, errorMessage) {
          details = details! + errorMessage[0];
          _logger
              .severe("Validation error for property $property: $errorMessage");
        });
      }
    } else {
      details = response.reasonPhrase;
    }

    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 400) {
      throw BaseException("$details");
    } else if (response.statusCode == 401) {
      throw BaseException("$details",
          type: ExceptionType.unauthorizedException);
    } else if (response.statusCode == 403) {
      throw BaseException("$details", type: ExceptionType.forbiddenException);
    } else {
      _logger.severe(details);
      throw BaseException("Something bad happened");
    }
  }

  /// Checks what status the StreamedResponse returned
  ///
  /// If the response is >=299, an exception is thrown depending on the status which should be handled externally
  Future<String?> _isValidStreamedResponse(
      http.StreamedResponse response) async {
    String? details;

    String responseBody = await response.stream.bytesToString();

    if (responseBody.isNotEmpty && response.statusCode >= 299) {
      details = jsonDecode(responseBody)["detail"];

      // Need to parse validation errors
      if (details == null) {
        details = "";
        var errorBody = jsonDecode(responseBody);
        Map<String, dynamic> validationErrors = errorBody['errors'];

        validationErrors.forEach((property, errorMessage) {
          details = details! + errorMessage[0];
          _logger
              .severe("Validation error for property $property: $errorMessage");
        });
      }
    } else {
      details = response.reasonPhrase;
    }

    if (response.statusCode < 299) {
      return responseBody;
    } else if (response.statusCode == 400) {
      throw BaseException("$details");
    } else if (response.statusCode == 401) {
      throw BaseException("$details",
          type: ExceptionType.unauthorizedException);
    } else if (response.statusCode == 403) {
      throw BaseException("$details", type: ExceptionType.forbiddenException);
    } else {
      _logger.severe(responseBody);
      throw BaseException("Something bad happened");
    }
  }

  /// Attempts to retrieve a new access token using the stored refresh token
  ///
  /// Returns true if new access credentials were stored
  ///
  /// If the token cannot be refreshed, all stored credentials are deleted and the login session is considered terminated
  @protected
  Future<bool> attemptTokenRefresh() async {
    var refreshToken = await SecureStore.getValue("refresh_token");
    Map<String, String> query = {
      "id": await SecureStore.getValue("user_ref_id") ?? ""
    };

    var headers = _createHeaders(bearerToken: refreshToken ?? "");
    var queryString = _getQueryString(query);
    var url = Uri.parse("${apiUrl}users/login/refresh?$queryString");

    var refreshResponse = await http.get(url, headers: headers);
    var refreshResult = QueryResult<UserLogin>();

    try {
      if (_isValidResponse(refreshResponse)) {
        var data = jsonDecode(refreshResponse.body);

        refreshResult.page = data["page"];
        refreshResult.totalCount = data["totalCount"];
        refreshResult.totalPages = data["totalPages"];

        for (var item in data["result"]) {
          refreshResult.result.add(UserLogin.fromJson(item));
        }

        if (refreshResult.result[0].accessToken != null) {
          _logger.info("Succesfully refreshed access!");
          await storeLogin(
              loginCreds: refreshResult.result[0], shouldNotify: false);
          return true;
        }
      }
    } on BaseException {
      _logger.info("Could not refresh token");
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
  Map<String, String> _createHeaders(
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
  String _getQueryString(Map params,
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
              _getQueryString({k: v}, prefix: "$prefix$key", inRecursion: true);
        });
      }
    });

    return query;
  }

  /// Takes a multipart request, fills it with the necessary fields and files and returns it
  ///
  /// Parameters:
  /// - [request]: The MultiPart request
  /// - [fields]: Fields to post, if any
  /// - [files]: Files to post, if any
  http.MultipartRequest _setMultipartPayload({
    required http.MultipartRequest request,
    Map<String, dynamic>? fields,
    Map<String, TransferFile>? files,
  }) {
    if (fields != null) {
      fields.forEach((key, value) {
        if (value is String) {
          request.fields[key] = value;
        } else if (value is List) {
          for (var listItem in value) {
            request.files
                .add(http.MultipartFile.fromString(key, listItem.toString()));
          }
        } else {
          request.files
              .add(http.MultipartFile.fromString(key, value.toString()));
        }
      });
    }

    if (files != null) {
      files.forEach((fieldName, transferFile) async {
        MediaType mimeType;

        try {
          mimeType = MediaType.parse(
              transferFile.file.mimeType ?? "application/octet-stream");
        } on FormatException {
          mimeType = MediaType.parse("application/octet-stream");
        }

        request.files.add(http.MultipartFile(
          fieldName,
          http.ByteStream(transferFile.file.openRead()),
          await transferFile.file.length(),
          filename: transferFile.name,
          contentType: mimeType,
        ));
      });
    }

    return request;
  }

  /// Takes a request of type BaseRequest and returns a copy.
  /// If the request is of type MultipartRequest, then the fields and files should be cloned separately
  /// with a call to setMultipartPayload
  ///
  /// Parameters:
  /// - [request]: The request to copy
  http.BaseRequest _copyRequest(http.BaseRequest request) {
    http.BaseRequest requestCopy;

    if (request is http.Request) {
      requestCopy = http.Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
    } else if (request is http.MultipartRequest) {
      requestCopy = http.MultipartRequest(request.method, request.url);
    } else if (request is http.StreamedRequest) {
      throw BaseException('Copying streamed requests is not supported');
    } else {
      throw BaseException('Request type is unknown, cannot copy');
    }

    requestCopy
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..headers.addAll(request.headers);

    return requestCopy;
  }

  Future<QueryResult<T>> _handleGetResponse(http.Response response) async {
    var queryResult = QueryResult<T>();

    if (_isValidResponse(response)) {
      var data = jsonDecode(response.body);

      queryResult.page = data["page"];
      queryResult.totalCount = data["totalCount"];
      queryResult.totalPages = data["totalPages"];

      for (var item in data["result"]) {
        queryResult.result.add(fromJson(item));
      }
    }

    return queryResult;
  }

  Future<EntityResult<T>> _handleMultipartResponse(
      http.StreamedResponse response) async {
    var entityResult = EntityResult<T>();
    var responseBody = await _isValidStreamedResponse(response);

    if (responseBody != null) {
      var data = jsonDecode(responseBody);

      entityResult.message = data["message"];
      entityResult.result =
          data["result"] == null ? null : fromJson(data["result"]);

      return entityResult;
    }

    throw BaseException("Unknown error");
  }

  Future<EntityResult<T>> _handleResponse(http.Response response) async {
    var entityResult = EntityResult<T>();

    if (_isValidResponse(response)) {
      var data = jsonDecode(response.body);

      entityResult.message = data["message"];
      entityResult.result =
          data["result"] == null ? null : fromJson(data["result"]);

      return entityResult;
    }

    throw BaseException("Unknown error");
  }

  Future<TransferFile> _handleByteResponse(http.Response response) async {
    if (_isValidResponse(response)) {
      var bytes = response.bodyBytes;
      String? contentDisposition = response.headers['content-disposition'];
      String? contentType = response.headers['content-type'];
      String filename = "file";
      String mimeType = "application/octet-stream";

      if (contentDisposition != null && contentDisposition.isNotEmpty) {
        var filenameRegex = RegExp('filename=.+;');
        var match = filenameRegex.firstMatch(contentDisposition);

        if (match != null) {
          filename = match.group(0) ?? "";
          filename = filename.replaceAll("filename=", "").replaceAll(";", "");
        }
      }

      if (contentType != null && contentType.isNotEmpty) {
        mimeType = contentType;
      }

      return TransferFile(
          XFile.fromData(bytes, name: filename, mimeType: mimeType), filename);
    }

    throw BaseException("Unknown error");
  }

  void _handleInternalAppError(Object? error, StackTrace stackTrace) {
    _logger.severe("Internal app error", error, stackTrace);

    String message = "";
    late ExceptionType type;

    if (error is SocketException) {
      message = "Could not make connection to the API.";
      type = ExceptionType.socketException;
    } else {
      message = "Internal app error. This could also be a server-side issue.";
      type = ExceptionType.internalAppError;
    }

    throw BaseException(message, type: type);
  }
}
