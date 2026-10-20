class CCRepresentanteModel {
  final String data;
  final String prePedido;
  final String descricao;
  final String debito;
  final String credito;
  final String saldo;

  CCRepresentanteModel({
    required this.data,
    required this.prePedido,
    required this.descricao,
    required this.debito,
    required this.credito,
    required this.saldo,
  });

  factory CCRepresentanteModel.fromJson(Map<String, dynamic> json) {
    return CCRepresentanteModel(
      data: json['DATA']?.toString() ?? '',
      prePedido: json['PREPEDIDO']?.toString() ?? '',
      descricao: json['DESCRICAO']?.toString() ?? '',
      debito: json['DEBITO']?.toString() ?? '0,00',
      credito: json['CREDITO']?.toString() ?? '0,00',
      saldo: json['SALDO']?.toString() ?? '0,00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DATA': data,
      'PREPEDIDO': prePedido,
      'DESCRICAO': descricao,
      'DEBITO': debito,
      'CREDITO': credito,
      'SALDO': saldo,
    };
  }
}
