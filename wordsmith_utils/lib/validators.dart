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

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter an email!";
  }

  // Not even going to try and explain this, it should correspond to any email format
  const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r"[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]"
      r"[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]"
      r"[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\"
      r"x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])";
  final regex = RegExp(pattern);

  return regex.hasMatch(value) ? null : "Enter a valid email address!";
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter a password!";
  }

  // Contains at least one digit and one special character, between 6 and 20 characters in length
  final regex = RegExp(
      r'^(?=.*?[A-Za-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{6,20}$');

  if (!regex.hasMatch(value)) {
    return "Password must be between 6 and 20 characters, contain one special character and one digit";
  }

  return null;
}

String? validateEBookTitle(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter a title!";
  }

  if (value.length > 40) {
    return "The title must be 40 characters or less!";
  }

  return null;
}

String? validateEBookDescription(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter a description!";
  }

  if (value.length > 800) {
    return "The description must be 800 characters or less!";
  }

  return null;
}

String? validateRequired(String? value) {
  if (value == null || value.isEmpty) {
    return "This field is required";
  }

  return null;
}
