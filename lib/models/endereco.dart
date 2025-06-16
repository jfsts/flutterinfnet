class Endereco {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String localidade;
  final String uf;
  final String ibge;
  final String gia;
  final String ddd;
  final String siafi;
  final bool erro;

  Endereco({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.ibge,
    required this.gia,
    required this.ddd,
    required this.siafi,
    this.erro = false,
  });

  /// Factory para criar Endereco a partir de JSON do ViaCEP
  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
      ibge: json['ibge'] ?? '',
      gia: json['gia'] ?? '',
      ddd: json['ddd'] ?? '',
      siafi: json['siafi'] ?? '',
      erro: json['erro'] ?? false,
    );
  }

  /// Converte Endereco para JSON
  Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'complemento': complemento,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'ibge': ibge,
      'gia': gia,
      'ddd': ddd,
      'siafi': siafi,
      'erro': erro,
    };
  }

  /// Retorna o endereço formatado para exibição
  String get enderecoFormatado {
    if (erro || logradouro.isEmpty) {
      return 'CEP: $cep (endereço não encontrado)';
    }

    final parts = <String>[];

    if (logradouro.isNotEmpty) parts.add(logradouro);
    if (bairro.isNotEmpty) parts.add(bairro);
    if (localidade.isNotEmpty && uf.isNotEmpty) {
      parts.add('$localidade/$uf');
    }
    if (cep.isNotEmpty) parts.add('CEP: $cep');

    return parts.join(', ');
  }

  /// Retorna endereço resumido (sem CEP)
  String get enderecoResumo {
    if (erro || logradouro.isEmpty) {
      return 'Endereço não encontrado';
    }

    final parts = <String>[];

    if (logradouro.isNotEmpty) parts.add(logradouro);
    if (bairro.isNotEmpty) parts.add(bairro);
    if (localidade.isNotEmpty && uf.isNotEmpty) {
      parts.add('$localidade/$uf');
    }

    return parts.join(', ');
  }

  /// Verifica se o endereço é válido
  bool get isValido => !erro && logradouro.isNotEmpty;

  @override
  String toString() => enderecoFormatado;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Endereco && other.cep == cep;
  }

  @override
  int get hashCode => cep.hashCode;
}
