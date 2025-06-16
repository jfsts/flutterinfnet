import 'package:flutter_test/flutter_test.dart';
import 'package:infnet_validators/infnet_validators.dart';

void main() {
  group('EmailValidator', () {
    test('deve validar emails válidos', () {
      expect(EmailValidator.validate('test@example.com').isValid, true);
      expect(EmailValidator.validate('user.name@domain.co.uk').isValid, true);
      expect(EmailValidator.validate('test+tag@example.org').isValid, true);
    });

    test('deve rejeitar emails inválidos', () {
      expect(EmailValidator.validate('').isValid, false);
      expect(EmailValidator.validate('invalid-email').isValid, false);
      expect(EmailValidator.validate('@domain.com').isValid, false);
      expect(EmailValidator.validate('test@').isValid, false);
      expect(EmailValidator.validate('test@domain').isValid, false);
    });

    test('deve retornar mensagens de erro apropriadas', () {
      expect(EmailValidator.validate('').errorMessage, 'Email é obrigatório');
      expect(EmailValidator.validate('a@b').errorMessage, 'Email muito curto');
      expect(EmailValidator.validate('invalid').errorMessage,
          'Formato de email inválido');
    });

    test('validateForForm deve retornar null para emails válidos', () {
      expect(EmailValidator.validateForForm('test@example.com'), null);
    });

    test('validateForForm deve retornar erro para emails inválidos', () {
      expect(EmailValidator.validateForForm('invalid'), isNotNull);
    });
  });
}
