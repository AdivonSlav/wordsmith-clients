import 'package:json_annotation/json_annotation.dart';

part "translation_response.g.dart";

@JsonSerializable(createToJson: false)
class TranslationResponse {
  final String originalText;
  final String translation;
  final String originalLanguageCode;
  final String translatedLanguageCode;

  const TranslationResponse({
    required this.originalText,
    required this.translation,
    required this.originalLanguageCode,
    required this.translatedLanguageCode,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) =>
      _$TranslationResponseFromJson(json);
}
