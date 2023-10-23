import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/image_insert.dart";

part "user_update.g.dart";

@JsonSerializable()
class UserUpdate {
  String? username;
  String? email;
  String? password;
  String? oldPassword;
  ImageInsert? profileImage;

  UserUpdate(
      {this.username,
      this.email,
      this.password,
      this.oldPassword,
      this.profileImage});

  factory UserUpdate.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateToJson(this);
}
