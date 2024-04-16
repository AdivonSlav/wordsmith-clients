import 'package:json_annotation/json_annotation.dart';
import 'package:wordsmith_utils/models/dictionary/dictionary_headword.dart';

part "dictionary_entry.g.dart";

@JsonSerializable(createToJson: false)
class DictionaryEntry {
  final int homograph;
  final String? date;
  final DictionaryHeadword headword;
  final String? functionalLabel;
  final List<String> shortDefs;
  final String? etymology;

  const DictionaryEntry(
    this.homograph,
    this.date,
    this.headword,
    this.functionalLabel,
    this.shortDefs,
    this.etymology,
  );

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) =>
      _$DictionaryEntryFromJson(json);
}
