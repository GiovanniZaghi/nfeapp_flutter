import 'model/consult_product_model.dart';
import 'model/consult_price_model.dart';

abstract class IConsultProductRepository {
  Future<List<ConsultProductModel>> getProducts([
    int? tabela,
    String? tabelaTexto,
  ]);
  Future<ConsultPriceModel?> getProductPrices(String codigo);
}
