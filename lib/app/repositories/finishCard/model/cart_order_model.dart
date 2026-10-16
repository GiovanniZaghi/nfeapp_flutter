class CartOrderModel {
  final String idProduto;
  final int quantidade;
  final String preco;

  CartOrderModel({
    required this.idProduto,
    required this.quantidade,
    required this.preco,
  });

  CartOrderModel copyWith({String? idProduto, int? quantidade, String? preco}) {
    return CartOrderModel(
      idProduto: idProduto ?? this.idProduto,
      quantidade: quantidade ?? this.quantidade,
      preco: preco ?? this.preco,
    );
  }
}
