import 'package:shared_preferences/shared_preferences.dart';
import '../../core/rest/rest_client.dart';
import 'i_order_repository.dart';
import 'model/detail_model.dart';
import 'model/product_model.dart';
import 'model/order_model.dart';

class OrderRepository implements IOrderRepository {
  final RestClient _rest;
  late SharedPreferences prefs;

  OrderRepository({required RestClient rest}) : _rest = rest;

  Future<void> reloadBaseUrl() async {
    prefs = await SharedPreferences.getInstance();
    final host = prefs.getString("host") ?? '';
    final port = prefs.getString("port") ?? '';
    await _rest.reloadBaseUrl();
  }

  @override
  Future<List<ProductModel>> getProducts([String? tabela]) async {
    try {
      await reloadBaseUrl();

      final tabelaEnviada =
          (tabela != null && tabela.trim().isNotEmpty)
              ? tabela.trim()
              : (prefs.getInt('tabelaPreco') ?? 2).toString();

      print("Qual tabela tem ? ${tabelaEnviada}");

      final response = await _rest.get(
        '/datasnap/rest/TServerAPPnfe/PesquisaProd//${tabelaEnviada.toUpperCase()}',
      );
      final data = response.data;
      if (data is List) {
        return ProductModel.fromJsonList(data);
      } else {
        return [];
      }
    } catch (_) {
      return [ProductModel()];
    }
  }

  Future<List<OrderModel>> getOrders({String implemented = "NÃO"}) async {
    try {
      prefs = await SharedPreferences.getInstance();
      final userCode = prefs.getString('userCodigo') ?? '';
      final companyCode = prefs.getString('companyCodigo') ?? '';
      if (userCode.isEmpty || companyCode.isEmpty) return [];
      await reloadBaseUrl();
      final url =
          '/datasnap/rest/TServerAPPnfe/RetornaSitPedido/$userCode/$companyCode/$implemented';
      final response = await _rest.get(url);
      final data = response.data;
      if (data is List &&
          data.isNotEmpty &&
          (data[0]['PEDIDO'] == null || data[0]['PEDIDO'].toString().isEmpty)) {
        return [];
      }
      return OrderModel.fromJsonList(data);
    } catch (_) {
      return [];
    }
  }

  Future<List<OrderModel>> getImplementedOrders() async {
    return getOrders(implemented: "SIM");
  }

  Future<List<OrderModel>> getNotImplementedOrders() async {
    return getOrders(implemented: "NÃO");
  }

  Future<List<OrderDetailModel>> getOrderDetails({
    required String pedido,
    required bool implemented,
  }) async {
    try {
      await reloadBaseUrl();
      final endpoint =
          implemented
              ? '/datasnap/rest/TServerAPPnfe/ConsultaPedido/$pedido'
              : '/datasnap/rest/TServerAPPnfe/RetornaItemPedido/$pedido';
      final response = await _rest.get(endpoint);
      final data = response.data;
      if (data is List) {
        return OrderDetailModel.fromJsonList(data);
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
