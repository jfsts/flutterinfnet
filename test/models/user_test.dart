import 'package:flutter_test/flutter_test.dart';
import 'package:projetoflutterinfnet/models/user.dart';

void main() {
  group('User Model Tests', () {
    group('Criação de User', () {
      test('deve criar User com todos os parâmetros', () {
        // Arrange & Act
        final user = User(
          id: 'test-id-123',
          email: 'test@example.com',
          name: 'Test User',
          password: 'password123',
        );

        // Assert
        expect(user.id, equals('test-id-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.name, equals('Test User'));
        expect(user.password, equals('password123'));
      });

      test('deve criar User com valores vazios', () {
        // Arrange & Act
        final user = User(
          id: '',
          email: '',
          name: '',
          password: '',
        );

        // Assert
        expect(user.id, equals(''));
        expect(user.email, equals(''));
        expect(user.name, equals(''));
        expect(user.password, equals(''));
      });
    });

    group('toJson', () {
      test('deve converter User para JSON corretamente', () {
        // Arrange
        final user = User(
          id: 'test-id-123',
          email: 'test@example.com',
          name: 'Test User',
          password: 'password123',
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('test-id-123'));
        expect(json['email'], equals('test@example.com'));
        expect(json['name'], equals('Test User'));
        expect(json['password'], equals('password123'));
      });

      test('deve converter User com valores vazios para JSON', () {
        // Arrange
        final user = User(
          id: '',
          email: '',
          name: '',
          password: '',
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals(''));
        expect(json['email'], equals(''));
        expect(json['name'], equals(''));
        expect(json['password'], equals(''));
      });
    });

    group('fromJson', () {
      test('deve criar User a partir de JSON válido', () {
        // Arrange
        final json = {
          'id': 'test-id-123',
          'email': 'test@example.com',
          'name': 'Test User',
          'password': 'password123',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, equals('test-id-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.name, equals('Test User'));
        expect(user.password, equals('password123'));
      });

      test('deve criar User a partir de JSON com valores nulos', () {
        // Arrange
        final json = {
          'id': null,
          'email': null,
          'name': null,
          'password': null,
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, equals(''));
        expect(user.email, equals(''));
        expect(user.name, isNull);
        expect(user.password, equals(''));
      });

      test('deve criar User a partir de JSON vazio', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, equals(''));
        expect(user.email, equals(''));
        expect(user.name, isNull);
        expect(user.password, equals(''));
      });
    });

    group('Serialização completa', () {
      test('deve manter dados após toJson e fromJson', () {
        // Arrange
        final originalUser = User(
          id: 'test-id-123',
          email: 'test@example.com',
          name: 'Test User',
          password: 'password123',
        );

        // Act
        final json = originalUser.toJson();
        final reconstructedUser = User.fromJson(json);

        // Assert
        expect(reconstructedUser.id, equals(originalUser.id));
        expect(reconstructedUser.email, equals(originalUser.email));
        expect(reconstructedUser.name, equals(originalUser.name));
        expect(reconstructedUser.password, equals(originalUser.password));
      });

      test('deve manter dados vazios após toJson e fromJson', () {
        // Arrange
        final originalUser = User(
          id: '',
          email: '',
          name: '',
          password: '',
        );

        // Act
        final json = originalUser.toJson();
        final reconstructedUser = User.fromJson(json);

        // Assert
        expect(reconstructedUser.id, equals(originalUser.id));
        expect(reconstructedUser.email, equals(originalUser.email));
        expect(reconstructedUser.name, equals(originalUser.name));
        expect(reconstructedUser.password, equals(originalUser.password));
      });
    });

    group('Validações', () {
      test('deve identificar User com dados válidos', () {
        // Arrange
        final user = User(
          id: 'test-id-123',
          email: 'test@example.com',
          name: 'Test User',
          password: 'password123',
        );

        // Assert
        expect(user.id.isNotEmpty, isTrue);
        expect(user.email.contains('@'), isTrue);
        expect(user.name?.isNotEmpty ?? false, isTrue);
        expect(user.password.isNotEmpty, isTrue);
      });

      test('deve identificar User com dados inválidos', () {
        // Arrange
        final user = User(
          id: '',
          email: 'invalid-email',
          password: '',
        );

        // Assert
        expect(user.id.isEmpty, isTrue);
        expect(user.email.contains('@'), isFalse);
        expect(user.name?.isEmpty ?? true, isTrue);
        expect(user.password.isEmpty, isTrue);
      });
    });

    group('Comparação de Users', () {
      test('deve comparar Users corretamente', () {
        // Arrange
        final user1 = User(
          id: 'test-id-123',
          email: 'test@example.com',
          name: 'Test User',
          password: 'password123',
        );

        final user2 = User(
          id: 'test-id-123',
          email: 'test@example.com',
          name: 'Test User',
          password: 'password123',
        );

        final user3 = User(
          id: 'different-id',
          email: 'test@example.com',
          name: 'Test User',
          password: 'password123',
        );

        // Assert
        expect(user1.id, equals(user2.id));
        expect(user1.email, equals(user2.email));
        expect(user1.name, equals(user2.name));
        expect(user1.password, equals(user2.password));

        expect(user1.id, isNot(equals(user3.id)));
      });
    });
  });
}
