class ConsultPriceModel {
  final String codigo;
  final String precoAvista;
  final String precoPromo;
  final String precoFaturado;

  ConsultPriceModel({
    required this.codigo,
    required this.precoAvista,
    required this.precoPromo,
    required this.precoFaturado,
  });

  factory ConsultPriceModel.fromJson(Map<String, dynamic> json) {
    return ConsultPriceModel(
      codigo: json['CODIGO']?.toString() ?? '',
      precoAvista: json['PRC_AVISTA']?.toString() ?? '0',
      precoPromo: json['PRC_PROMO']?.toString() ?? '0',
      precoFaturado: json['PRC_FAT']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CODIGO': codigo,
      'PRC_AVISTA': precoAvista,
      'PRC_PROMO': precoPromo,
      'PRC_FAT': precoFaturado,
    };
  }

  static List<ConsultPriceModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => ConsultPriceModel.fromJson(e)).toList();
  }
}
