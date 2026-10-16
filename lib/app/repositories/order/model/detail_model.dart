class OrderDetailModel {
  final String codProd;
  final String produto;
  final String quant;
  final String prcUnit;
  final String total;
  final String condicao;
  final String forma;

  OrderDetailModel({
    required this.codProd,
    required this.produto,
    required this.quant,
    required this.prcUnit,
    required this.total,
    required this.condicao,
    required this.forma,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      codProd: json['CODPROD']?.toString() ?? '',
      produto: json['PRODUTO']?.toString() ?? '',
      quant: json['QUANT']?.toString() ?? '',
      prcUnit: json['PRCUNIT']?.toString() ?? '',
      total: json['TOTAL']?.toString() ?? '',
      condicao: json['CONDICAO']?.toString() ?? '',
      forma: json['FORMA']?.toString() ?? '',
    );
  }

  static List<OrderDetailModel> fromJsonList(dynamic data) {
    if (data is List) {
      return data.map((e) => OrderDetailModel.fromJson(e)).toList();
    }
    return [];
  }
}
