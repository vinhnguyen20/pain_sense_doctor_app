class AppValidators {
  AppValidators._();

  // RFC 5322 compliant simplified email regex
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  // International phone number: optional +, then 8 to 15 digits (ignoring spaces, dashes, dots, parentheses)
  static final RegExp _phoneCharactersRegExp = RegExp(r'^[+0-9\s\-().]+$');

  // Name: Unicode letters (supports Vietnamese accents), spaces, hyphens, apostrophes
  static final RegExp _nameRegExp = RegExp(
    r"^[\p{L}\s'\-]+$",
    unicode: true,
  );

  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid email address (e.g. name@example.com).';
    }
    return null;
  }

  /// Validates a phone number.
  static String? validatePhone(String? value, {String fieldName = 'phone number'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a $fieldName.';
    }
    final trimmed = value.trim();
    if (!_phoneCharactersRegExp.hasMatch(trimmed)) {
      return 'The $fieldName contains invalid characters.';
    }
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 8 || digitsOnly.length > 15) {
      return 'The $fieldName must contain between 8 and 15 digits.';
    }
    return null;
  }

  /// Validates a person's first or last name.
  static String? validateName(String? value, {String fieldName = 'name'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName.';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters.';
    }
    if (!_nameRegExp.hasMatch(trimmed)) {
      return '$fieldName can only contain letters.';
    }
    return null;
  }

  /// Validates a password.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 6) {
      return 'Password must contain at least 6 characters.';
    }
    return null;
  }

  /// Validates password confirmation.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Validates age.
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your age.';
    }
    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Age must be a valid whole number.';
    }
    if (age <= 0 || age > 120) {
      return 'Please enter a realistic age between 1 and 120.';
    }
    return null;
  }

  /// Validates a generic required field.
  static String? validateRequired(String? value, {String fieldName = 'field'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName.';
    }
    return null;
  }
}
