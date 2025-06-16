import 'package:flutter_test/flutter_test.dart';
import 'package:infnet_validators/infnet_validators.dart';

void main() {
  group('EmailValidator', () {
    test('deve validar email válido', () {
      final result = EmailValidator.validate('teste@exemplo.com');
      expect(result.isValid, true);
    });

    test('deve rejeitar email inválido', () {
      final result = EmailValidator.validate('email_invalido');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Formato de email inválido');
    });

    test('deve rejeitar email vazio', () {
      final result = EmailValidator.validate('');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Email é obrigatório');
    });
  });

  group('PasswordValidator', () {
    test('deve validar senha válida', () {
      final result = PasswordValidator.validateSimple('123456');
      expect(result.isValid, true);
    });

    test('deve rejeitar senha muito curta', () {
      final result = PasswordValidator.validateSimple('123');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Senha deve ter pelo menos 6 caracteres');
    });

    test('deve validar confirmação de senha', () {
      final result = PasswordValidator.validateConfirmation('123456', '123456');
      expect(result.isValid, true);
    });

    test('deve rejeitar senhas diferentes', () {
      final result = PasswordValidator.validateConfirmation('123456', '654321');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Senhas não coincidem');
    });
  });

  group('NameValidator', () {
    test('deve validar nome válido', () {
      final result = NameValidator.validateSimple('João');
      expect(result.isValid, true);
    });

    test('deve rejeitar nome muito curto', () {
      final result = NameValidator.validateSimple('A');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Nome deve ter pelo menos 2 caracteres');
    });

    test('deve formatar nome corretamente', () {
      final formatted = NameValidator.formatName('joão silva');
      expect(formatted, 'João Silva');
    });

    test('deve validar nome completo', () {
      final result = NameValidator.validateFullName('João Silva');
      expect(result.isValid, true);
    });

    test('deve rejeitar nome incompleto', () {
      final result = NameValidator.validateFullName('João');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Digite nome e sobrenome');
    });
  });

  group('CepValidator', () {
    test('deve validar CEP válido', () {
      final result = CepValidator.validate('12345678');
      expect(result.isValid, true);
    });

    test('deve validar CEP formatado', () {
      final result = CepValidator.validate('12345-678');
      expect(result.isValid, true);
    });

    test('deve rejeitar CEP inválido', () {
      final result = CepValidator.validate('00000000');
      expect(result.isValid, false);
      expect(result.errorMessage, 'CEP inválido');
    });

    test('deve formatar CEP corretamente', () {
      final formatted = CepValidator.formatCep('12345678');
      expect(formatted, '12345-678');
    });

    test('deve limpar formatação do CEP', () {
      final cleaned = CepValidator.cleanCep('12345-678');
      expect(cleaned, '12345678');
    });
  });
}
