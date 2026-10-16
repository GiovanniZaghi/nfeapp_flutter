import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'i_commission_repository.dart';
import 'model/commission_model.dart';

class CommissionRepository implements ICommissionRepository {
  String? baseUrl;

  CommissionRepository();

  Future<void> configureBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host');
    final port = prefs.getString('port');
    baseUrl = 'http://$host:$port/datasnap/rest/TServerAPPnfe';
  }

  Future<void> reloadBaseUrl() async {
    await configureBaseUrl();
  }

  @override
  Future<List<CommissionModel>> getCommissions({
    required String clientId,
    required String startDate,
    required String endDate,
  }) async {
    if (baseUrl == null) {
      await configureBaseUrl();
    }

    final url = Uri.parse('$baseUrl/Comissao/$clientId/$startDate/$endDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CommissionModel.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar comissões: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
