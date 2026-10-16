import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'i_finish_cart_repository.dart';
import 'model/cart_model.dart';
import 'model/cart_order_model.dart';

class FinishCartRepository implements IFinishCartRepository {
  late String baseUrl;

  FinishCartRepository();

  Future<void> loadHostFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host');
    final port = prefs.getString('port');

    if (host == null || port == null) {
      throw Exception(
        "Host ou porta não encontrados no SharedPreferences. Faça login primeiro.",
      );
    }

    baseUrl = 'http://$host:$port/datasnap/rest/TServerAPPnfe';
  }

  Future<void> reloadBaseUrl() async {
    try {
      await loadHostFromPrefs();
      log("✅ Base URL recarregada: $baseUrl");
    } catch (e) {
      log("⚠️ Erro ao recarregar baseUrl: $e");
      rethrow;
    }
  }

  @override
  Future<String> incluirPedido() async {
    if (baseUrl.isEmpty) await loadHostFromPrefs();
    final url = Uri.parse("$baseUrl/IncluirPedido");
    log("IncluirPedido URL: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final numPed = response.body.replaceAll('"', '');
      log("IncluirPedido Response: $numPed");
      return numPed;
    } else {
      throw Exception("Erro IncluirPedido: ${response.statusCode}");
    }
  }

  @override
  Future<void> gravaPed1(CartModel pedido, String numPed) async {
    if (baseUrl.isEmpty) await loadHostFromPrefs();

    final descontoStr = pedido.valDesc.isEmpty ? "0" : pedido.valDesc;
    final obs =
        pedido.obsPed.isEmpty ? "-" : Uri.encodeComponent(pedido.obsPed);
    final total = pedido.totalPed.isEmpty ? "0,00" : pedido.totalPed;
    final numPedCliente =
        pedido.numPedCliente.isEmpty
            ? "-"
            : Uri.encodeComponent(pedido.numPedCliente);
    final tabela =
        pedido.tabela.isEmpty ? "-" : Uri.encodeComponent(pedido.tabela);

    // Ordem definida pelo Fabio: empresa/numPed/pedidoCliente/representante/
    // cliente/tipoPagto/condPagto/desconto/obs/total/tabela.
    final url = Uri.parse(
      "$baseUrl/GravaPed1/"
      "${pedido.idEmpresa}/$numPed/$numPedCliente/${pedido.idVendedor}/"
      "${pedido.idCliente}/${pedido.idTpPag}/${pedido.idCondPag}/"
      "$descontoStr/$obs/$total/$tabela",
    );

    log("GravaPed1 URL: $url");

    final response = await http.get(url);

    log("GravaPed1 Status: ${response.statusCode}");
    log("GravaPed1 Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Erro GravaPed1: ${response.statusCode}");
    }
  }

  @override
  Future<void> gravaPed2(
    String idVendedor,
    String numPed,
    CartOrderModel produto,
  ) async {
    if (baseUrl.isEmpty) await loadHostFromPrefs();

    final precoStr = produto.preco.isEmpty ? "0,00" : produto.preco;

    // Ordem definida pelo Fabio: representante/numPed/produto/qtd/valorUnit.
    final url = Uri.parse(
      "$baseUrl/GravaPed2/$idVendedor/$numPed/${produto.idProduto}/${produto.quantidade}/$precoStr",
    );

    log("GravaPed2 URL: $url");

    final response = await http.get(url);

    log("GravaPed2 Status: ${response.statusCode}");
    log("GravaPed2 Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Erro GravaPed2: ${response.statusCode}");
    }
  }

  @override
  Future<bool> enviarPedido(CartModel pedido) async {
    try {
      await reloadBaseUrl();

      final numPed = await incluirPedido();
      await gravaPed1(pedido, numPed);

      for (final item in pedido.produtos) {
        await gravaPed2(pedido.idVendedor, numPed, item);
      }

      final urlConfirma = Uri.parse("$baseUrl/ConfirmaPed/$numPed");
      log("ConfirmaPed URL: $urlConfirma");

      final response = await http.get(urlConfirma);

      log("ConfirmaPed Status: ${response.statusCode}");
      log("ConfirmaPed Body: ${response.body}");

      if (response.statusCode == 200) {
        final confirmado = response.body.replaceAll('"', '').toUpperCase();
        log("ConfirmaPed Response: $confirmado");
        return confirmado == 'T';
      } else {
        throw Exception("Erro ConfirmaPed: ${response.statusCode}");
      }
    } catch (e) {
      log("Erro ao enviar pedido: $e");
      return false;
    }
  }
}
