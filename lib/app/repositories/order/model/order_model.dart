class OrderModel {
  final String pedido;
  final String data;
  final String cliente;
  final String total;
  final String desconto;

  OrderModel({
    this.pedido = '',
    this.data = '',
    this.cliente = '',
    this.total = '',
    this.desconto = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      pedido: json['PEDIDO']?.toString() ?? '',
      data: json['DATA']?.toString() ?? '',
      cliente: json['CLIENTE']?.toString() ?? '',
      total: json['TOTAL']?.toString() ?? '',
      desconto: json['DESCONTO']?.toString() ?? '',
    );
  }

  static List<OrderModel> fromJsonList(dynamic data) {
    if (data is List) {
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  String toString() =>
      'OrderModel(pedido: $pedido, cliente: $cliente, data: $data, total: $total, desconto: $desconto)';
}
