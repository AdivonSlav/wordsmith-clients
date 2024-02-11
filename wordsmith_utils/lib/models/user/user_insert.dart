import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/image/image_insert.dart";

part "user_insert.g.dart";

@JsonSerializable()
class UserInsert {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final ImageInsert? profileImage;

  UserInsert(
    this.username,
    this.email,
    this.password,
    this.confirmPassword,
    this.profileImage,
  );

  factory UserInsert.fromJson(Map<String, dynamic> json) =>
      _$UserInsertFromJson(json);

  Map<String, dynamic> toJson() => _$UserInsertToJson(this);
}
