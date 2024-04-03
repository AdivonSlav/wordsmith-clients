import 'package:json_annotation/json_annotation.dart';

part "user_login_request.g.dart";

@JsonSerializable()
class UserLoginRequest {
  final String username;
  final String password;
  final String? clientId;

  const UserLoginRequest({
    required this.username,
    required this.password,
    this.clientId,
  });

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginRequestToJson(this);
}
