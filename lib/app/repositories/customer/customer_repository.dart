import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/dao/cart/custummer_dao.dart';
import 'i_customer_repository.dart';
import 'model/customer_model.dart';

class CustomerRepository implements ICustomerRepository {
  String? baseUrl;
  final dao = CustomerDao();

  CustomerRepository();

  Future<void> configureBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('host');
    final port = prefs.getString('port');

    if (host == null || port == null) {
      throw Exception('Host ou porta não encontrados. Faça login novamente.');
    }

    baseUrl = 'http://$host:$port/datasnap/rest/TServerAPPnfe';
  }

  Future<void> reloadBaseUrl() async {
    await configureBaseUrl();
  }

  @override
  Future<List<CustomerModel>> getCustomers() async {
    if (baseUrl == null || baseUrl!.isEmpty) {
      await configureBaseUrl();
    }

    final prefs = await SharedPreferences.getInstance();
    final repId = prefs.getString('repId') ?? '';

    final url = Uri.parse('$baseUrl/pesquisaCliente//$repId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final customers =
            data.map((json) => CustomerModel.fromJson(json)).toList();

        await dao.saveCustomers(customers);
        return customers;
      } else {
        return await dao.getCustomers();
      }
    } catch (_) {
      return await dao.getCustomers();
    }
  }
}
