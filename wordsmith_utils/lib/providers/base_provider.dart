import "dart:convert";
import "package:flutter/foundation.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:http/http.dart" as http;

abstract class BaseProvider<T> with ChangeNotifier {
  String _endpoint = "";
  static String? _apiUrl;

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _apiUrl = const String.fromEnvironment("API_URL");
  }

  Future<QueryResult<T>> get(
      {String additionalEndpoint = "",
      dynamic filter,
      String bearerToken = ""}) async {
    var url = "$_apiUrl$_endpoint$additionalEndpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (error) {
      print("Invalid URL: $url");
      print(error);
      throw Exception(error);
    }

    var headers = createHeaders(bearerToken: bearerToken);
    var response = await http.get(uri, headers: headers);
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

  T fromJson(dynamic data) {
    throw UnimplementedError();
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 400) {
      throw BaseException(
          "Bad request: ${jsonDecode(response.body)["detail"]}");
    } else if (response.statusCode == 401) {
      throw BaseException(
          "Unauthorized: ${jsonDecode(response.body)["detail"]}");
    } else if (response.statusCode == 403) {
      throw BaseException("Forbidden: ${jsonDecode(response.body)["detail"]}");
    } else {
      print(response.body);
      throw BaseException("Something bad happened");
    }
  }

  Map<String, String> createHeaders({String bearerToken = ""}) {
    Map<String, String> headers = {"Content-Type": "application/json"};

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
