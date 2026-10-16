import 'package:sqflite/sqflite.dart';
import '../../../../repositories/product/model/consult_product_model.dart';
import '../../database.dart';

class ConsultProductDao {
  static const String tableConsultProduct = 'consult_product';

  static const String createTableConsultProduct = '''
    CREATE TABLE IF NOT EXISTS $tableConsultProduct (
      CODIGO TEXT PRIMARY KEY,
      PRODUTO TEXT,
      PRECO TEXT,
      ESTOQUE TEXT,
      IMAGEM TEXT,
      QUANTIDADE INTEGER
    )
  ''';

  Future<void> saveProducts(List<ConsultProductModel> products) async {
    final db = await getDatabase();
    final batch = db.batch();

    batch.delete(tableConsultProduct);

    for (var p in products) {
      batch.insert(
        tableConsultProduct,
        p.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<ConsultProductModel>> getProducts() async {
    final db = await getDatabase();
    final result = await db.query(tableConsultProduct);

    return result.map((e) => ConsultProductModel.fromJson(e)).toList();
  }

  Future<void> updateQuantity(String codigo, int quantidade) async {
    final db = await getDatabase();
    await db.update(
      tableConsultProduct,
      {'QUANTIDADE': quantidade},
      where: 'CODIGO = ?',
      whereArgs: [codigo],
    );
  }
}
