import 'package:json_annotation/json_annotation.dart';
import 'package:wordsmith_utils/models/dictionary/dictionary_pronunciation.dart';

part "dictionary_headword.g.dart";

@JsonSerializable(createToJson: false)
class DictionaryHeadword {
  final String? text;
  final List<DictionaryPronunciation> pronunciations;

  const DictionaryHeadword(this.text, this.pronunciations);

  factory DictionaryHeadword.fromJson(Map<String, dynamic> json) =>
      _$DictionaryHeadwordFromJson(json);
}
