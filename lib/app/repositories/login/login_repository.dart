import 'dart:convert';
import 'dart:developer';
import 'package:nfeapp_flutter/app/core/api/api_session.dart';
import 'package:nfeapp_flutter/app/core/rest/http/http_rest_client.dart';
import 'package:nfeapp_flutter/app/repositories/login/model/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'i_login_repository.dart';

class LoginRepository implements ILoginRepository {
  final HttpRestClient _restClient;
  late SharedPreferences prefs;

  LoginRepository({required HttpRestClient restClient})
    : _restClient = restClient;

  Future<void> checkUrl(String cnpj) async {
    try {
      prefs = await SharedPreferences.getInstance();

      await prefs.remove('host');
      await prefs.remove('port');

      final url =
          'http://aplicativo.dyndns-work.com:9090/datasnap/rest/TserverAPPnfe/LoginEmpresa/$cnpj';
      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body);

      log("Rota Json > $jsonData");

      if (jsonData.isNotEmpty) {
        final host = jsonData[0]['SERVIDOR'].toString().toLowerCase();
        final port = jsonData[0]['PORTA'].toString().toLowerCase();

        await prefs.setString('host', host);
        await prefs.setString('port', port);

        await _restClient.setBaseUrl(host, port);
      } else {}
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LoginModel> login(String login, String password) async {
    try {
      prefs = await SharedPreferences.getInstance();

      login = login.toUpperCase();
      password = password.toUpperCase();

      final host = prefs.getString('host');
      final port = prefs.getString('port');

      final path =
          '/datasnap/rest/${ApiSession.module}/LoginApp/$login/$password';
      final response = await _restClient.get(path);
      final jsonData = response.data;

      if (jsonData == null || jsonData.isEmpty) {
        return LoginModel();
      }

      final res = LoginModel.fromJson(jsonData[0]);

      if (res.validado == "T") {
        await prefs.setString('userLogin', login);
        await prefs.setString('userCodigo', res.codigo ?? '');
        await prefs.setString('companyCodigo', res.empresa ?? '');
        await prefs.setString('userFantasia', res.fantasia ?? 'Nome pendente');
        await prefs.setString(
          'userEmail',
          res.email?.isNotEmpty == true ? res.email! : 'Email pendente',
        );
        await prefs.setString(
          'multitab',
          res.multitab?.toUpperCase() == 'T' ? 'T' : 'F',
        );
        await prefs.setString('repId', res.idRepr ?? '');

        if (res.imagem64 != null && res.imagem64!.isNotEmpty) {
          await prefs.setString('userImagem64', res.imagem64!);
        }
      }

      return res;
    } catch (e) {
      return LoginModel();
    }
  }

  Future<void> logout() async {
    prefs = await SharedPreferences.getInstance();

    await prefs.remove('userLogin');
    await prefs.remove('userCodigo');
    await prefs.remove('companyCodigo');
    await prefs.remove('userFantasia');
    await prefs.remove('userEmail');
    await prefs.remove('userImagem64');
    await prefs.remove('multitab');
    await prefs.remove('repId');
    await prefs.remove('host');
    await prefs.remove('port');
  }
}
