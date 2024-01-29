import 'dart:convert';

import 'package:wordsmith_utils/models/ebook.dart';
import 'package:wordsmith_utils/models/ebook_insert.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/transfer_file.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/secure_store.dart';

class EBookProvider extends BaseProvider<EBook> {
  EBookProvider() : super("ebooks");

  Future<QueryResult<EBook>> getNewlyAdded(
      {required int page, required int pageSize}) async {
    var accessToken = await SecureStore.getValue("access_token");

    Map<String, String> query = {
      "page": page.toString(),
      "pageSize": pageSize.toString(),
      "orderBy": "UpdatedDate:desc"
    };

    return await get(
        filter: query, bearerToken: accessToken ?? "", retryForRefresh: true);
  }

  Future<EBook> postEBook(EBookInsert insert, TransferFile file) async {
    var accessToken = await SecureStore.getValue("access_token");

    Map<String, dynamic> fields = {
      "title": insert.title,
      "description": insert.description,
      "encodedCoverArt": insert.encodedCoverArt,
      "chapters": jsonEncode(insert.chapters),
      "authorId": insert.authorId.toString(),
      "genreIds": insert.genreIds,
      "maturityRatingId": insert.maturityRatingId.toString(),
    };

    Map<String, TransferFile> files = {"file": file};

    return await postMultipart(
      files: files,
      fields: fields,
      bearerToken: accessToken ?? "",
    );
  }

  @override
  EBook fromJson(data) {
    return EBook.fromJson(data);
  }
}
