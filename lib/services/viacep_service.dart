import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/endereco.dart';

class ViaCepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';
  static const Duration _timeout = Duration(seconds: 10);

  /// Busca endereço por CEP
  ///
  /// Parâmetros:
  /// - [cep]: CEP no formato "12345678" ou "12345-678"
  ///
  /// Retorna:
  /// - [Endereco] com dados preenchidos se CEP for válido
  /// - [Endereco] com erro=true se CEP for inválido ou não encontrado
  /// - null em caso de erro na requisição
  Future<Endereco?> buscarEnderecoPorCep(String cep) async {
    try {
      // Limpar e validar CEP
      final cepLimpo = _limparCep(cep);
      if (!_validarCep(cepLimpo)) {
        return Endereco(
          cep: cep,
          logradouro: '',
          complemento: '',
          bairro: '',
          localidade: '',
          uf: '',
          ibge: '',
          gia: '',
          ddd: '',
          siafi: '',
          erro: true,
        );
      }

      // Fazer requisição para ViaCEP
      final url = Uri.parse('$_baseUrl/$cepLimpo/json/');
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // ViaCEP retorna {"erro": true} quando CEP não existe
        if (data['erro'] == true || data['erro'] == 'true') {
          return Endereco(
            cep: cep,
            logradouro: '',
            complemento: '',
            bairro: '',
            localidade: '',
            uf: '',
            ibge: '',
            gia: '',
            ddd: '',
            siafi: '',
            erro: true,
          );
        }

        return Endereco.fromJson(data);
      } else {
        print('Erro na requisição ViaCEP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar CEP: $e');
      return null;
    }
  }

  /// Busca múltiplos endereços por cidade e logradouro
  ///
  /// Exemplo: buscarEnderecosPorCidadeLogradouro("RS", "Porto Alegre", "Domingos")
  Future<List<Endereco>> buscarEnderecosPorCidadeLogradouro(
    String uf,
    String cidade,
    String logradouro,
  ) async {
    try {
      if (uf.length != 2 || cidade.length < 3 || logradouro.length < 3) {
        return [];
      }

      final url = Uri.parse(
        '$_baseUrl/$uf/$cidade/$logradouro/json/',
      );
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data
              .map((json) => Endereco.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          // Se retornou objeto único (erro ou endereço único)
          final endereco = Endereco.fromJson(data as Map<String, dynamic>);
          return endereco.erro ? [] : [endereco];
        }
      } else {
        print('Erro na requisição ViaCEP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar endereços: $e');
      return [];
    }
  }

  /// Remove formatação do CEP (hífens, espaços, etc.)
  String _limparCep(String cep) {
    return cep.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Valida se CEP tem formato correto (8 dígitos)
  bool _validarCep(String cep) {
    return cep.length == 8 && RegExp(r'^[0-9]{8}$').hasMatch(cep);
  }

  /// Formatar CEP para exibição (12345678 -> 12345-678)
  static String formatarCep(String cep) {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length == 8) {
      return '${cepLimpo.substring(0, 5)}-${cepLimpo.substring(5)}';
    }
    return cep;
  }

  /// Verifica se CEP tem formato válido para busca
  static bool isCepValido(String cep) {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cepLimpo.length == 8;
  }

  /// Testa conectividade com ViaCEP usando CEP conhecido
  Future<bool> testarConectividade() async {
    try {
      // Usa CEP da Av. Paulista, SP (sempre existe)
      final resultado = await buscarEnderecoPorCep('01310-100');
      return resultado != null && resultado.isValido;
    } catch (e) {
      print('Erro no teste de conectividade: $e');
      return false;
    }
  }
}
