import 'validation_result.dart';

/// Validador de CEP brasileiro
class CepValidator {
  static final RegExp _cepPattern = RegExp(r'^\d{5}-?\d{3}$');
  static final RegExp _numbersOnly = RegExp(r'[^\d]');

  /// Valida CEP brasileiro
  static ValidationResult validate(String? cep) {
    if (cep == null || cep.trim().isEmpty) {
      return const ValidationResult.invalid('CEP é obrigatório');
    }

    final cleanCep = cep.replaceAll(_numbersOnly, '');

    if (cleanCep.length != 8) {
      return const ValidationResult.invalid('CEP deve ter 8 dígitos');
    }

    // Verifica se não é um CEP inválido conhecido
    if (cleanCep == '00000000' ||
        cleanCep == '11111111' ||
        cleanCep == '22222222' ||
        cleanCep == '33333333' ||
        cleanCep == '44444444' ||
        cleanCep == '55555555' ||
        cleanCep == '66666666' ||
        cleanCep == '77777777' ||
        cleanCep == '88888888' ||
        cleanCep == '99999999') {
      return const ValidationResult.invalid('CEP inválido');
    }

    return const ValidationResult.valid();
  }

  /// Valida CEP para uso em TextFormField
  static String? validateForForm(String? cep) {
    final result = validate(cep);
    return result.isValid ? null : result.errorMessage;
  }

  /// Formata CEP brasileiro (12345-678)
  static String formatCep(String cep) {
    final cleanCep = cep.replaceAll(_numbersOnly, '');

    if (cleanCep.length == 8) {
      return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
    }

    return cep; // Retorna original se não conseguir formatar
  }

  /// Remove formatação do CEP
  static String cleanCep(String cep) {
    return cep.replaceAll(_numbersOnly, '');
  }

  /// Verifica se o CEP está formatado
  static bool isFormatted(String cep) {
    return _cepPattern.hasMatch(cep);
  }
}
