import 'model/customer_model.dart';

abstract class ICustomerRepository {
  Future<List<CustomerModel>> getCustomers();
}
