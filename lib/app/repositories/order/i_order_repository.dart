import 'package:nfeapp_flutter/app/repositories/order/model/product_model.dart';

abstract class IOrderRepository {
  Future<List<ProductModel>> getProducts([String? tabela]);
}
