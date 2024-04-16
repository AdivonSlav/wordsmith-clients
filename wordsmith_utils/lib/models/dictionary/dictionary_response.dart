import 'package:json_annotation/json_annotation.dart';
import 'package:wordsmith_utils/models/dictionary/dictionary_entry.dart';

part "dictionary_response.g.dart";

@JsonSerializable(createToJson: false)
class DictionaryResponse {
  final String searchTerm;
  final List<DictionaryEntry> entries;

  const DictionaryResponse(this.searchTerm, this.entries);

  factory DictionaryResponse.fromJson(Map<String, dynamic> json) =>
      _$DictionaryResponseFromJson(json);
}
