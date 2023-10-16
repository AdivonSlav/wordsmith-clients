library wordsmith_utils;

String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter a username!";
  }

  if (value.length > 20 || value.length < 3) {
    return "Username must be between 3 and 20 characters";
  }

  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter a password!";
  }

  // Contains at least one digit and one special character
  RegExp regex =
      RegExp(r"^(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-])$");

  if (!regex.hasMatch(value)) {
    return "Password must contain at least one digit and one special character";
  }

  return null;
}

String? validateRequired(String? value) {
  if (value == null || value.isEmpty) {
    return "This field is required";
  }

  return null;
}
