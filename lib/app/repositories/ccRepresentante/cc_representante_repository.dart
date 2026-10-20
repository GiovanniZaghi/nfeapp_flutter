import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'i_cc_representante_repository.dart';
import 'model/cc_representante_model.dart';

class CCRepresentanteRepository implements ICCRepresentanteRepository {
  String? baseUrl;

  CCRepresentanteRepository();

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
  Future<List<CCRepresentanteModel>> getExtrato() async {
    if (baseUrl == null) {
      await configureBaseUrl();
    }

    final prefs = await SharedPreferences.getInstance();
    final repId = prefs.getString('repId') ?? '';

    final url = Uri.parse('$baseUrl/RetornaCCRepresent/$repId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CCRepresentanteModel.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar extrato: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
