class CustomerModel {
  final String codigo;
  final String cliente;
  final String endereco;
  final String bairro;
  final String cidade;
  final String uf;
  final String restricao;
  final String limiteCredito;

  CustomerModel({
    required this.codigo,
    required this.cliente,
    required this.endereco,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.restricao,
    required this.limiteCredito,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      codigo: json['CODIGO']?.toString() ?? '',
      cliente: json['CLIENTE']?.toString().trim() ?? '',
      endereco: json['ENDERECO']?.toString() ?? '',
      bairro: json['BAIRRO']?.toString() ?? '',
      cidade: json['CIDADE']?.toString() ?? '',
      uf: json['UF']?.toString() ?? '',
      restricao: json['RESTRICAO']?.toString() ?? '',
      limiteCredito: json['LIMITE_CREDITO']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CODIGO': codigo,
      'CLIENTE': cliente,
      'ENDERECO': endereco,
      'BAIRRO': bairro,
      'CIDADE': cidade,
      'UF': uf,
      'RESTRICAO': restricao,
      'LIMITE_CREDITO': limiteCredito,
    };
  }
}
