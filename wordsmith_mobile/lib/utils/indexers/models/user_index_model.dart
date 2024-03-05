class UserIndexModel {
  int id;
  String username;
  String email;
  String encodedProfileImage;
  DateTime registrationDate;

  static const String _idColumn = "id";
  static const String _usernameColumn = "username";
  static const String _emailColumn = "email";
  static const String _encodedProfileImageColumn = "encodedProfileImage";
  static const String _registrationDateColumn = "registrationDateColumn";

  static String get idColumn => _idColumn;
  static String get usernameColumn => _usernameColumn;
  static String get emailColumn => _emailColumn;
  static String get encodedProfileImageColumn => _encodedProfileImageColumn;
  static String get registrationDateColumn => _registrationDateColumn;

  UserIndexModel({
    required this.id,
    required this.username,
    required this.email,
    required this.encodedProfileImage,
    required this.registrationDate,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      _idColumn: id,
      _usernameColumn: username,
      _emailColumn: email,
      _encodedProfileImageColumn: encodedProfileImage,
      _registrationDateColumn: registrationDate.millisecondsSinceEpoch,
    };

    return map;
  }

  UserIndexModel.fromMap(Map<String, Object?> map)
      : id = map[_idColumn] as int,
        username = map[_usernameColumn] as String,
        email = map[_emailColumn] as String,
        encodedProfileImage = map[_encodedProfileImageColumn] as String,
        registrationDate = DateTime.fromMillisecondsSinceEpoch(
          map[_registrationDateColumn] as int,
          isUtc: true,
        );
}
