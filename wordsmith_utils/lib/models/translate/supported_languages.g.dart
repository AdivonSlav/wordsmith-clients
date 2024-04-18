// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supported_languages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportedLanguages _$SupportedLanguagesFromJson(Map<String, dynamic> json) =>
    SupportedLanguages(
      (json['languages'] as List<dynamic>)
          .map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
