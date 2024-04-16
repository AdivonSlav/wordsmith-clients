// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryResponse _$DictionaryResponseFromJson(Map<String, dynamic> json) =>
    DictionaryResponse(
      json['searchTerm'] as String,
      (json['entries'] as List<dynamic>)
          .map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
