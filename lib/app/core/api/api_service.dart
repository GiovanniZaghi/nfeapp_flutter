import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'api_session.dart';

class ApiService {
  final http.Client _client;
  final Duration timeout;

  ApiService({http.Client? client, this.timeout = const Duration(seconds: 15)})
    : _client = client ?? http.Client();

  static String segment(Object? value) =>
      Uri.encodeComponent(value?.toString().trim() ?? '');

  Future<ApiSession> session() => ApiSession.load();

  Future<String> getText(String path) async {
    final session = await ApiSession.load();
    final uri = Uri.parse('${session.baseUrl}/$path');

    try {
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode != 200) {
        throw ApiException('Servidor respondeu ${response.statusCode}.');
      }

      return response.body.replaceAll('"', '').trim();
    } on TimeoutException {
      throw const ApiException('Tempo esgotado ao falar com o servidor.');
    } on SocketException {
      throw const ApiException('Sem conexão com o servidor.');
    } on http.ClientException {
      throw const ApiException('Sem conexão com o servidor.');
    }
  }

  Future<List<dynamic>> getList(String path) async {
    final session = await ApiSession.load();
    final uri = Uri.parse('${session.baseUrl}/$path');

    try {
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode != 200) {
        throw ApiException('Servidor respondeu ${response.statusCode}.');
      }

      final body = response.body.trim();
      if (body.isEmpty) return [];

      final decoded = jsonDecode(body);
      if (decoded is! List) {
        throw const ApiException('Resposta inesperada do servidor.');
      }
      return decoded;
    } on TimeoutException {
      throw const ApiException('Tempo esgotado ao falar com o servidor.');
    } on SocketException {
      throw const ApiException('Sem conexão com o servidor.');
    } on http.ClientException {
      throw const ApiException('Sem conexão com o servidor.');
    } on FormatException {
      throw const ApiException('Resposta inesperada do servidor.');
    }
  }

  Future<bool> getTF(String path) async {
    final text = await getText(path);
    return text.toUpperCase() == 'T';
  }
}
