import 'package:json_annotation/json_annotation.dart';

part "user_library_insert.g.dart";

@JsonSerializable()
class UserLibraryInsert {
  final int eBookId;
  final String? orderReferenceId;

  UserLibraryInsert({
    required this.eBookId,
    required this.orderReferenceId,
  });

  factory UserLibraryInsert.fromJson(Map<String, dynamic> json) =>
      _$UserLibraryInsertFromJson(json);

  Map<String, dynamic> toJson() => _$UserLibraryInsertToJson(this);
}
