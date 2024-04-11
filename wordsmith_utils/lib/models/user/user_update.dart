import "package:json_annotation/json_annotation.dart";

part "user_update.g.dart";

@JsonSerializable()
class UserUpdate {
  String username;
  String email;
  String about;
  String? password;
  String? oldPassword;

  UserUpdate({
    required this.username,
    required this.email,
    required this.about,
    this.password,
    this.oldPassword,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateToJson(this);
}
