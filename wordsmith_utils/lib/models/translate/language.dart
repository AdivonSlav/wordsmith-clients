import 'package:json_annotation/json_annotation.dart';

part "language.g.dart";

@JsonSerializable(createToJson: false)
class Language {
  final String name;
  final String languageCode;

  const Language(this.name, this.languageCode);

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);
}
