import 'validation_result.dart';

/// Validador de email
class EmailValidator {
  static const String _emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  static final RegExp _emailRegex = RegExp(_emailPattern);

  /// Valida se o email está em formato válido
  static ValidationResult validate(String? email) {
    if (email == null || email.trim().isEmpty) {
      return const ValidationResult.invalid('Email é obrigatório');
    }

    final trimmedEmail = email.trim();

    if (trimmedEmail.length < 5) {
      return const ValidationResult.invalid('Email muito curto');
    }

    if (trimmedEmail.length > 254) {
      return const ValidationResult.invalid('Email muito longo');
    }

    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return const ValidationResult.invalid('Formato de email inválido');
    }

    return const ValidationResult.valid();
  }

  /// Valida email para uso em TextFormField
  static String? validateForForm(String? email) {
    final result = validate(email);
    return result.isValid ? null : result.errorMessage;
  }
}
