class TipoPagamentoModel {
  final String codigo;
  final String descricao;

  TipoPagamentoModel({required this.codigo, required this.descricao});

  factory TipoPagamentoModel.fromJson(Map<String, dynamic> json) {
    return TipoPagamentoModel(
      codigo: json['CODIGO']?.toString() ?? '',
      descricao: json['FORMAPAGTO']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'CODIGO': codigo, 'FORMAPAGTO': descricao};
  }
}

class CondicaoPagamentoModel {
  final String codigo;
  final String descricao;

  CondicaoPagamentoModel({required this.codigo, required this.descricao});

  factory CondicaoPagamentoModel.fromJson(Map<String, dynamic> json) {
    return CondicaoPagamentoModel(
      codigo: json['CODIGO']?.toString() ?? '',
      descricao: json['FORMAPAGTO']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'CODIGO': codigo, 'FORMAPAGTO': descricao};
  }
}
