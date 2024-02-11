import 'package:json_annotation/json_annotation.dart';

part "user_library_category.g.dart";

@JsonSerializable()
class UserLibraryCategory {
  final int id;
  final int userId;
  final String name;

  UserLibraryCategory(
    this.id,
    this.userId,
    this.name,
  );

  factory UserLibraryCategory.fromJson(Map<String, dynamic> json) =>
      _$UserLibraryCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$UserLibraryCategoryToJson(this);
}
