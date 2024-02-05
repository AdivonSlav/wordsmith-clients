import 'package:json_annotation/json_annotation.dart';

part "user_library_insert.g.dart";

@JsonSerializable()
class UserLibraryInsert {
  final int eBookId;
  final int userId;

  UserLibraryInsert(this.eBookId, this.userId);

  factory UserLibraryInsert.fromJson(Map<String, dynamic> json) =>
      _$UserLibraryInsertFromJson(json);

  Map<String, dynamic> toJson() => _$UserLibraryInsertToJson(this);
}
