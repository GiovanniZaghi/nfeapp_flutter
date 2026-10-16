import 'package:sqflite/sqflite.dart';
import '../../../../repositories/customer/model/customer_model.dart';
import '../../database.dart';

class CustomerDao {
  static const String tableCustomer = 'customers';

  static const String createTableCustomer = '''
    CREATE TABLE IF NOT EXISTS $tableCustomer (
      CODIGO TEXT PRIMARY KEY,
      CLIENTE TEXT,
      ENDERECO TEXT,
      BAIRRO TEXT,
      CIDADE TEXT,
      UF TEXT,
      RESTRICAO TEXT,
      LIMITE_CREDITO TEXT
    )
  ''';

  Future<void> saveCustomers(List<CustomerModel> customers) async {
    final db = await getDatabase();
    final batch = db.batch();

    batch.delete(tableCustomer);

    for (var c in customers) {
      batch.insert(
        tableCustomer,
        c.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<CustomerModel>> getCustomers() async {
    final db = await getDatabase();

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='${tableCustomer}'",
    );
    if (tables.isEmpty) {
      return [];
    }

    final result = await db.query(tableCustomer);
    return result.map((e) => CustomerModel.fromJson(e)).toList();
  }
}
