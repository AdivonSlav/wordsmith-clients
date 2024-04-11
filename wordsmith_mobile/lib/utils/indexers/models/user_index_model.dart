import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_status.dart';

class UserIndexModel {
  int id;
  String username;
  String email;
  String encodedProfileImage;
  DateTime registrationDate;

  static const String idColumn = "id";
  static const String usernameColumn = "username";
  static const String emailColumn = "email";
  static const String encodedProfileImageColumn = "encoded_profile_image";
  static const String registrationDateColumn = "registration_date";

  UserIndexModel({
    required this.id,
    required this.username,
    required this.email,
    required this.encodedProfileImage,
    required this.registrationDate,
  });

  User toUser() {
    var user = User(
      id,
      username,
      email,
      null,
      registrationDate,
      UserStatus.active,
      "",
    );

    return user;
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      idColumn: id,
      usernameColumn: username,
      emailColumn: email,
      encodedProfileImageColumn: encodedProfileImage,
      registrationDateColumn: registrationDate.millisecondsSinceEpoch,
    };

    return map;
  }

  UserIndexModel.fromMap(Map<String, Object?> map)
      : id = map[idColumn] as int,
        username = map[usernameColumn] as String,
        email = map[emailColumn] as String,
        encodedProfileImage = map[encodedProfileImageColumn] as String,
        registrationDate = DateTime.fromMillisecondsSinceEpoch(
          map[registrationDateColumn] as int,
          isUtc: true,
        );
}
