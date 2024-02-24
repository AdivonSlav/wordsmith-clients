import 'package:json_annotation/json_annotation.dart';

part "user_library_category_remove.g.dart";

@JsonSerializable()
class UserLibraryCategoryRemove {
  final List<int> userLibraryIds;

  UserLibraryCategoryRemove({required this.userLibraryIds});

  factory UserLibraryCategoryRemove.fromJson(Map<String, dynamic> json) =>
      _$UserLibraryCategoryRemoveFromJson(json);

  Map<String, dynamic> toJson() => _$UserLibraryCategoryRemoveToJson(this);
}
