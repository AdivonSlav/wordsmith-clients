import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/user.dart";

part "user_login.g.dart";

@JsonSerializable()
class UserLogin {
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresIn;
  final User user;

  UserLogin(this.accessToken, this.refreshToken, this.expiresIn, this.user);

  factory UserLogin.fromJson(Map<String, dynamic> json) =>
      _$UserLoginFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginToJson(this);
}
