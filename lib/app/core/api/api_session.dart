import 'package:shared_preferences/shared_preferences.dart';

import 'api_exception.dart';

class ApiSession {
  static const module = 'TServerAPPnfe';

  final String host;
  final String port;
  final String repId;
  final String empresaId;
  final bool multitab;

  const ApiSession({
    required this.host,
    required this.port,
    required this.repId,
    required this.empresaId,
    required this.multitab,
  });

  String get baseUrl => 'http://$host:$port/datasnap/rest/$module';

  static Future<ApiSession> load() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host') ?? '';
    final port = prefs.getString('port') ?? '';
    final repId = prefs.getString('repId') ?? '';

    if (host.isEmpty || port.isEmpty) {
      throw const ApiException(
        'Servidor não configurado. Faça login novamente.',
      );
    }

    if (repId.isEmpty) {
      throw const ApiException(
        'Representante não identificado. Faça login novamente.',
      );
    }

    return ApiSession(
      host: host,
      port: port,
      repId: repId,
      empresaId: prefs.getString('companyCodigo') ?? '',
      multitab: prefs.getString('multitab') == 'T',
    );
  }

  // Lê só o MULTITAB salvo no login, sem exigir host/port/repId.
  // Usado para decidir se o campo de tabela aparece na tela, mesmo que a
  // sessão completa (checada em load()) esteja com algum outro dado faltando.
  static Future<bool> isMultitab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('multitab') == 'T';
  }
}
