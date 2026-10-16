class ProductModel {
  String? codigo;
  String? produto;
  String? preco;
  String? estoque;
  String? imagem;

  ProductModel({
    this.codigo,
    this.produto,
    this.preco,
    this.estoque,
    this.imagem,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    codigo = json['CODIGO'];
    produto = json['PRODUTO'];
    preco = json['PRECO'];
    estoque = json['ESTOQUE'];
    imagem = json['IMAGEM'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CODIGO'] = this.codigo;
    data['PRODUTO'] = this.produto;
    data['PRECO'] = this.preco;
    data['ESTOQUE'] = this.estoque;
    data['IMAGEM'] = this.imagem;
    return data;
  }

  static List<ProductModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  String toString() {
    return 'ProductModel{codigo: $codigo, produto: $produto, preco: $preco, estoque: $estoque, imagem: $imagem}';
  }
}
