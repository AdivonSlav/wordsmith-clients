// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryEntry _$DictionaryEntryFromJson(Map<String, dynamic> json) =>
    DictionaryEntry(
      json['homograph'] as int,
      json['date'] as String?,
      DictionaryHeadword.fromJson(json['headword'] as Map<String, dynamic>),
      json['functionalLabel'] as String?,
      (json['shortDefs'] as List<dynamic>).map((e) => e as String).toList(),
      json['etymology'] as String?,
    );
