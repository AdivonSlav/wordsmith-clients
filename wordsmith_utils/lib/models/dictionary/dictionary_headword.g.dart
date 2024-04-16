// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_headword.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryHeadword _$DictionaryHeadwordFromJson(Map<String, dynamic> json) =>
    DictionaryHeadword(
      json['text'] as String?,
      (json['pronunciations'] as List<dynamic>)
          .map((e) =>
              DictionaryPronunciation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
