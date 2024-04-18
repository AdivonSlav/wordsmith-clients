import 'package:json_annotation/json_annotation.dart';
import 'package:wordsmith_utils/models/translate/language.dart';

part "supported_languages.g.dart";

@JsonSerializable(createToJson: false)
class SupportedLanguages {
  final List<Language> languages;

  const SupportedLanguages(this.languages);

  factory SupportedLanguages.fromJson(Map<String, dynamic> json) =>
      _$SupportedLanguagesFromJson(json);
}
