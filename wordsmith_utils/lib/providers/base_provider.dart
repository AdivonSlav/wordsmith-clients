import "dart:convert";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/exceptions/forbidden_exception.dart";
import "package:wordsmith_utils/exceptions/unauthorized_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:http/http.dart" as http;
import "package:http_parser/http_parser.dart";
import "package:wordsmith_utils/models/transfer_file.dart";
import "package:wordsmith_utils/models/user_login.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/secure_store.dart";

abstract class BaseProvider<T> extends AuthProvider {
  static final _logger = LogManager.getLogger("BaseProvider");
  String _endpoint = "";
  static String? _apiUrl;

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _apiUrl = const String.fromEnvironment("API_URL");
  }

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
    var response = await http.get(uri, headers: headers);

    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        response = await http.get(uri, headers: headers);
      } else {
        throw UnauthorizedException("Failed despite a token refresh attempt");
      }
    }

    var queryResult = QueryResult<T>();

    if (isValidResponse(response)) {
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
    var response = await http.put(uri, body: jsonRequest, headers: headers);

    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        response = await http.put(uri, body: jsonRequest, headers: headers);
      } else {
        throw UnauthorizedException("Failed despite a token refresh attempt");
      }
    }

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    }

    throw Exception("Unknown error");
  }

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
    var response = await http.post(uri, body: jsonRequest, headers: headers);

    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        response = await http.post(uri, body: jsonRequest, headers: headers);
      } else {
        throw UnauthorizedException("Failed despite a token refresh attempt");
      }
    }

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    }

    throw Exception("Unknown error");
  }

  Future<T> postMultipart(
      {Map<String, String>? fields,
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

    var request = http.MultipartRequest('POST', uri);

    if (fields != null) {
      request.fields.addAll(fields);
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

    var response = await request.send();

    if (retryForRefresh == true && response.statusCode == 401) {
      var success = await attemptTokenRefresh();

      if (success == true) {
        bearerToken = await SecureStore.getValue("access_token") ?? "";
        response = await request.send();
      } else {
        throw UnauthorizedException("Failed despite a token refresh attempt");
      }
    }

    var responseBody = await isValidStreamedResponse(response);

    if (responseBody != null) {
      var data = jsonDecode(responseBody);
      return fromJson(data);
    }

    throw Exception("Unknown error");
  }

  T fromJson(dynamic data) {
    throw UnimplementedError();
  }

  bool isValidResponse(http.Response response) {
    String? details;

    if (response.body.isNotEmpty) {
      details = jsonDecode(response.body)["detail"];
    } else {
      details = response.reasonPhrase;
    }

    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 400) {
      throw BaseException("Bad request: $details");
    } else if (response.statusCode == 401) {
      throw UnauthorizedException("$details");
    } else if (response.statusCode == 403) {
      throw ForbiddenException("$details");
    } else {
      _logger.severe(response.body);
      throw BaseException("Something bad happened");
    }
  }

  Future<String?> isValidStreamedResponse(
      http.StreamedResponse response) async {
    String? details;

    String responseBody = await response.stream.bytesToString();

    if (responseBody.isNotEmpty) {
      details = jsonDecode(responseBody)["detail"];
    } else {
      details = response.reasonPhrase;
    }

    if (response.statusCode < 299) {
      return responseBody;
    } else if (response.statusCode == 400) {
      throw BaseException("Bad request: $details");
    } else if (response.statusCode == 401) {
      throw UnauthorizedException("$details");
    } else if (response.statusCode == 403) {
      throw ForbiddenException("$details");
    } else {
      _logger.severe(responseBody);
      throw BaseException("Something bad happened");
    }
  }

  Future<bool> attemptTokenRefresh() async {
    var refreshToken = await SecureStore.getValue("refresh_token");
    Map<String, String> query = {
      "id": await SecureStore.getValue("user_ref_id") ?? ""
    };

    var headers = createHeaders(bearerToken: refreshToken ?? "");
    var queryString = getQueryString(query);
    var url = Uri.parse("${_apiUrl}users/login/refresh?$queryString");

    var refreshResponse = await http.get(url, headers: headers);
    var refreshResult = QueryResult<UserLogin>();

    try {
      if (isValidResponse(refreshResponse)) {
        var data = jsonDecode(refreshResponse.body);

        refreshResult.page = data["page"];
        refreshResult.totalCount = data["totalCount"];
        refreshResult.totalPages = data["totalPages"];

        for (var item in data["result"]) {
          refreshResult.result.add(UserLogin.fromJson(item));
        }

        if (refreshResult.result[0].accessToken != null) {
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
}
