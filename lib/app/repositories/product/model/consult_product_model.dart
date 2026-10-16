class ConsultProductModel {
  final String codigo;
  final String produto;
  final String preco;
  final String estoque;
  final String imagem;
  int quantidade;
  String obs;

  ConsultProductModel({
    required this.codigo,
    required this.produto,
    required this.preco,
    required this.estoque,
    required this.imagem,
    this.quantidade = 0,
    this.obs = '',
  });

  factory ConsultProductModel.fromJson(Map<String, dynamic> json) {
    return ConsultProductModel(
      codigo: json['CODIGO']?.toString() ?? '',
      produto: json['PRODUTO']?.toString() ?? '',
      preco: (json['PRECO'] ?? json['PRCUNIT'])?.toString() ?? '0',
      estoque: json['ESTOQUE']?.toString() ?? '0',
      imagem: '',
      quantidade:
          json['QUANTIDADE'] != null
              ? int.tryParse(json['QUANTIDADE'].toString()) ?? 0
              : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CODIGO': codigo,
      'PRODUTO': produto,
      'PRECO': preco,
      'ESTOQUE': estoque,
      'IMAGEM': imagem,
      'QUANTIDADE': quantidade,
    };
  }
}
