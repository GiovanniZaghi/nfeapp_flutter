import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/dao/cart/product_dao.dart';
import 'i_consult_product_repository.dart';
import 'model/consult_product_model.dart';
import 'model/consult_price_model.dart';

class ConsultProductRepository implements IConsultProductRepository {
  String baseUrl = '';
  String imageBaseUrl = '';
  final dao = ConsultProductDao();

  ConsultProductRepository();

  Future<void> reloadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host') ?? '';
    final port = prefs.getString('port') ?? '';

    baseUrl = 'http://$host:$port/datasnap/rest/TServerAPPnfe';
    imageBaseUrl = 'http://$host/Fotos';
  }

  @override
  Future<List<ConsultProductModel>> getProducts([
    int? tabela,
    String? tabelaTexto,
  ]) async {
    await reloadBaseUrl();

    // MULTITAB = T: tabela digitada pelo representante (nome livre, ex.: CMC30).
    // MULTITAB = F: mantém a tabela numérica fixa (1/2/3) já usada hoje.
    final String tabelaSelecionada;
    if (tabelaTexto != null && tabelaTexto.trim().isNotEmpty) {
      tabelaSelecionada = tabelaTexto.trim();
    } else {
      final prefs = await SharedPreferences.getInstance();
      tabelaSelecionada =
          (tabela ?? prefs.getInt('tabelaPreco') ?? 2).toString();
    }

    print("Qual tabela tem ? ${tabelaSelecionada}");

    final url = Uri.parse('$baseUrl/PesquisaProd//${tabelaSelecionada.toUpperCase()}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final products =
            data.map((jsonItem) {
              final product = ConsultProductModel.fromJson(jsonItem);
              return ConsultProductModel(
                codigo: product.codigo,
                produto: product.produto,
                preco: product.preco,
                estoque: product.estoque,
                imagem: '$imageBaseUrl/${product.codigo}-PRODUTO.jpg',
                quantidade: product.quantidade,
              );
            }).toList();

        await dao.saveProducts(products);
        return products;
      } else {
        return await dao.getProducts();
      }
    } catch (e, s) {
      return await dao.getProducts();
    }
  }

  @override
  Future<ConsultPriceModel?> getProductPrices(String codigo) async {
    await reloadBaseUrl();

    final url = Uri.parse('$baseUrl/ConsultaProduto/$codigo');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return ConsultPriceModel.fromJson(data.first);
        }
      }

      return null;
    } catch (e, s) {
      return null;
    }
  }
}
