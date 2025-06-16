import 'package:flutter_test/flutter_test.dart';
import '../lib/services/viacep_service.dart';

void main() {
  group('ViaCepService', () {
    late ViaCepService viaCepService;

    setUp(() {
      viaCepService = ViaCepService();
    });

    group('buscarEnderecoPorCep', () {
      test('deve retornar endereço válido para CEP existente', () async {
        // Arrange - CEP da Av. Paulista, SP
        const cep = '01310-100';

        // Act
        final resultado = await viaCepService.buscarEnderecoPorCep(cep);

        // Assert
        expect(resultado, isNotNull);
        expect(resultado!.isValido, isTrue);
        expect(resultado.cep, equals('01310-100'));
        expect(resultado.logradouro, contains('Paulista'));
        expect(resultado.localidade, equals('São Paulo'));
        expect(resultado.uf, equals('SP'));
        expect(resultado.erro, isFalse);
      });

      test('deve retornar erro para CEP inexistente', () async {
        // Arrange - CEP inválido
        const cep = '00000-000';

        // Act
        final resultado = await viaCepService.buscarEnderecoPorCep(cep);

        // Assert
        expect(resultado, isNotNull);
        expect(resultado!.erro, isTrue);
        expect(resultado.isValido, isFalse);
      });

      test('deve retornar erro para CEP com formato inválido', () async {
        // Arrange - CEP muito curto
        const cep = '123';

        // Act
        final resultado = await viaCepService.buscarEnderecoPorCep(cep);

        // Assert
        expect(resultado, isNotNull);
        expect(resultado!.erro, isTrue);
        expect(resultado.isValido, isFalse);
      });

      test('deve aceitar CEP com ou sem formatação', () async {
        // Arrange - Mesmo CEP com e sem hífen
        const cepComHifen = '01310-100';
        const cepSemHifen = '01310100';

        // Act
        final resultadoComHifen =
            await viaCepService.buscarEnderecoPorCep(cepComHifen);
        final resultadoSemHifen =
            await viaCepService.buscarEnderecoPorCep(cepSemHifen);

        // Assert
        expect(resultadoComHifen, isNotNull);
        expect(resultadoSemHifen, isNotNull);
        expect(resultadoComHifen!.isValido, isTrue);
        expect(resultadoSemHifen!.isValido, isTrue);
        expect(
            resultadoComHifen.logradouro, equals(resultadoSemHifen.logradouro));
      });
    });

    group('buscarEnderecosPorCidadeLogradouro', () {
      test('deve retornar lista de endereços para busca válida', () async {
        // Arrange
        const uf = 'SP';
        const cidade = 'São Paulo';
        const logradouro = 'Paulista';

        // Act
        final resultados =
            await viaCepService.buscarEnderecosPorCidadeLogradouro(
          uf,
          cidade,
          logradouro,
        );

        // Assert
        expect(resultados, isNotNull);
        expect(resultados, isNotEmpty);
        expect(resultados.first.uf, equals('SP'));
        expect(resultados.first.localidade, equals('São Paulo'));
      });

      test('deve retornar lista vazia para busca com parâmetros inválidos',
          () async {
        // Arrange - UF muito curta
        const uf = 'S';
        const cidade = 'São Paulo';
        const logradouro = 'Paulista';

        // Act
        final resultados =
            await viaCepService.buscarEnderecosPorCidadeLogradouro(
          uf,
          cidade,
          logradouro,
        );

        // Assert
        expect(resultados, isEmpty);
      });
    });

    group('Métodos utilitários', () {
      test('formatarCep deve formatar CEP corretamente', () {
        // Arrange & Act & Assert
        expect(ViaCepService.formatarCep('01310100'), equals('01310-100'));
        expect(ViaCepService.formatarCep('01310-100'), equals('01310-100'));
        expect(ViaCepService.formatarCep('123'),
            equals('123')); // CEP inválido mantém formato
      });

      test('isCepValido deve validar CEP corretamente', () {
        // Arrange & Act & Assert
        expect(ViaCepService.isCepValido('01310-100'), isTrue);
        expect(ViaCepService.isCepValido('01310100'), isTrue);
        expect(ViaCepService.isCepValido('123'), isFalse);
        expect(ViaCepService.isCepValido(''), isFalse);
        expect(ViaCepService.isCepValido('123456789'), isFalse);
      });
    });

    group('testarConectividade', () {
      test('deve retornar true quando conseguir conectar com ViaCEP', () async {
        // Act
        final conectado = await viaCepService.testarConectividade();

        // Assert
        expect(conectado, isTrue);
      });
    });
  });
}
