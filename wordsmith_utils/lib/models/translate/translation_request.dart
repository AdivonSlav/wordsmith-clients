import 'package:json_annotation/json_annotation.dart';

part "translation_request.g.dart";

@JsonSerializable(createFactory: false)
class TranslationRequest {
  final String text;
  final String targetLanguageCode;
  final String? sourceLanguageCode;

  const TranslationRequest({
    required this.text,
    required this.targetLanguageCode,
    this.sourceLanguageCode,
  });

  Map<String, dynamic> toJson() => _$TranslationRequestToJson(this);
}
