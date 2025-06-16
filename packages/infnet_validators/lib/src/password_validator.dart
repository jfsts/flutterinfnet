import 'validation_result.dart';

/// Validador de senha
class PasswordValidator {
  /// Valida senha com critérios de segurança
  static ValidationResult validate(
    String? password, {
    int minLength = 6,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumbers = false,
    bool requireSpecialChars = false,
  }) {
    if (password == null || password.isEmpty) {
      return const ValidationResult.invalid('Senha é obrigatória');
    }

    if (password.length < minLength) {
      return ValidationResult.invalid(
          'Senha deve ter pelo menos $minLength caracteres');
    }

    if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      return const ValidationResult.invalid(
          'Senha deve conter pelo menos uma letra maiúscula');
    }

    if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
      return const ValidationResult.invalid(
          'Senha deve conter pelo menos uma letra minúscula');
    }

    if (requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
      return const ValidationResult.invalid(
          'Senha deve conter pelo menos um número');
    }

    if (requireSpecialChars &&
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return const ValidationResult.invalid(
          'Senha deve conter pelo menos um caractere especial');
    }

    return const ValidationResult.valid();
  }

  /// Valida senha simples (apenas comprimento mínimo)
  static ValidationResult validateSimple(String? password) {
    return validate(password, minLength: 6);
  }

  /// Valida senha forte (todos os critérios)
  static ValidationResult validateStrong(String? password) {
    return validate(
      password,
      minLength: 8,
      requireUppercase: true,
      requireLowercase: true,
      requireNumbers: true,
      requireSpecialChars: true,
    );
  }

  /// Valida senha para uso em TextFormField
  static String? validateForForm(String? password) {
    final result = validateSimple(password);
    return result.isValid ? null : result.errorMessage;
  }

  /// Valida confirmação de senha
  static ValidationResult validateConfirmation(
      String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return const ValidationResult.invalid(
          'Confirmação de senha é obrigatória');
    }

    if (password != confirmation) {
      return const ValidationResult.invalid('Senhas não coincidem');
    }

    return const ValidationResult.valid();
  }

  /// Valida confirmação de senha para uso em TextFormField
  static String? validateConfirmationForForm(
      String? password, String? confirmation) {
    final result = validateConfirmation(password, confirmation);
    return result.isValid ? null : result.errorMessage;
  }
}
