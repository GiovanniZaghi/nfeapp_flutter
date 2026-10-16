import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/dao/cart/payment_dao.dart';
import 'model/payment_model.dart';

abstract class IPaymentRepository {
  Future<List<CondicaoPagamentoModel>> getCondicoesPagamento();
  Future<List<TipoPagamentoModel>> getTiposPagamento();
}

class PaymentRepository implements IPaymentRepository {
  String baseUrl = '';
  final dao = PaymentDao();

  PaymentRepository();

  Future<void> reloadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host') ?? '';
    final port = prefs.getString('port') ?? '';
    baseUrl = 'http://$host:$port/datasnap/rest/TServerAPPnfe';
  }

  @override
  Future<List<TipoPagamentoModel>> getTiposPagamento() async {
    await reloadBaseUrl();

    final url = Uri.parse('$baseUrl/RetornaTipoPagto');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final tipos =
            data.map((json) => TipoPagamentoModel.fromJson(json)).toList();
        await dao.saveTiposPagamento(tipos);
        return tipos;
      } else {
        return await dao.getTiposPagamento();
      }
    } catch (_) {
      return await dao.getTiposPagamento();
    }
  }

  @override
  Future<List<CondicaoPagamentoModel>> getCondicoesPagamento() async {
    await reloadBaseUrl();

    final prefs = await SharedPreferences.getInstance();
    final repId = prefs.getString('repId') ?? '';

    final url = Uri.parse('$baseUrl/RetornaCondPagto/$repId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = response.body.trim();

        if (body.startsWith('[') && body.endsWith(']')) {
          final List<dynamic> data = json.decode(body);
          final condicoes =
              data
                  .map((json) => CondicaoPagamentoModel.fromJson(json))
                  .toList();
          await dao.saveCondicoesPagamento(condicoes);
          return condicoes;
        } else {
          throw Exception('Resposta inesperada');
        }
      } else {
        return await dao.getCondicoesPagamento();
      }
    } catch (_) {
      return await dao.getCondicoesPagamento();
    }
  }
}
