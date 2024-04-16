import 'package:json_annotation/json_annotation.dart';

part "dictionary_pronunciation.g.dart";

@JsonSerializable(createToJson: false)
class DictionaryPronunciation {
  final String writtenPronunciation;
  final String? labelBefore;
  final String? labelAfter;
  final String? punctuation;

  const DictionaryPronunciation(
    this.writtenPronunciation,
    this.labelBefore,
    this.labelAfter,
    this.punctuation,
  );

  factory DictionaryPronunciation.fromJson(Map<String, dynamic> json) =>
      _$DictionaryPronunciationFromJson(json);
}
