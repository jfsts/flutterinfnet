import 'validation_result.dart';

/// Validador de nome
class NameValidator {
  /// Valida nome completo
  static ValidationResult validate(
    String? name, {
    int minLength = 2,
    int maxLength = 100,
    bool requireFullName = false,
  }) {
    if (name == null || name.trim().isEmpty) {
      return const ValidationResult.invalid('Nome é obrigatório');
    }

    final trimmedName = name.trim();

    if (trimmedName.length < minLength) {
      return ValidationResult.invalid(
          'Nome deve ter pelo menos $minLength caracteres');
    }

    if (trimmedName.length > maxLength) {
      return ValidationResult.invalid(
          'Nome deve ter no máximo $maxLength caracteres');
    }

    // Verifica se contém apenas letras, espaços e acentos
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(trimmedName)) {
      return const ValidationResult.invalid('Nome deve conter apenas letras');
    }

    // Verifica se tem pelo menos nome e sobrenome
    if (requireFullName && trimmedName.split(' ').length < 2) {
      return const ValidationResult.invalid('Digite nome e sobrenome');
    }

    return const ValidationResult.valid();
  }

  /// Valida nome simples (apenas um nome)
  static ValidationResult validateSimple(String? name) {
    return validate(name, minLength: 2, requireFullName: false);
  }

  /// Valida nome completo (nome + sobrenome)
  static ValidationResult validateFullName(String? name) {
    return validate(name, minLength: 3, requireFullName: true);
  }

  /// Valida nome para uso em TextFormField
  static String? validateForForm(String? name) {
    final result = validateSimple(name);
    return result.isValid ? null : result.errorMessage;
  }

  /// Valida nome completo para uso em TextFormField
  static String? validateFullNameForForm(String? name) {
    final result = validateFullName(name);
    return result.isValid ? null : result.errorMessage;
  }

  /// Formata nome (primeira letra maiúscula)
  static String formatName(String name) {
    if (name.trim().isEmpty) return name;

    return name.trim().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
