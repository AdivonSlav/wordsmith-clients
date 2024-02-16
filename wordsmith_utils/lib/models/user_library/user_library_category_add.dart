import 'package:json_annotation/json_annotation.dart';

part 'user_library_category_add.g.dart';

@JsonSerializable()
class UserLibraryCategoryAdd {
  final List<int> userLibraryIds;
  final int? userLibraryCategoryId;
  final String? newCategoryName;

  UserLibraryCategoryAdd(
    this.userLibraryIds,
    this.userLibraryCategoryId,
    this.newCategoryName,
  );

  factory UserLibraryCategoryAdd.fromJson(Map<String, dynamic> json) =>
      _$UserLibraryCategoryAddFromJson(json);

  Map<String, dynamic> toJson() => _$UserLibraryCategoryAddToJson(this);
}
