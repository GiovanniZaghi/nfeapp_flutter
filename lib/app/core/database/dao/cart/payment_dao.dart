import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database.dart';
import '../../../../repositories/payment/model/payment_model.dart';

class PaymentDao {
  static const String tableTipoPagamento = 'payment_type';
  static const String tableCondicaoPagamento = 'payment_condition';

  static const String createTableTipoPagamento = '''
    CREATE TABLE IF NOT EXISTS $tableTipoPagamento (
      CODIGO TEXT PRIMARY KEY,
      FORMAPAGTO TEXT
    )
  ''';

  static const String createTableCondicaoPagamento = '''
    CREATE TABLE IF NOT EXISTS $tableCondicaoPagamento (
      CODIGO TEXT PRIMARY KEY,
      FORMAPAGTO TEXT
    )
  ''';

  Future<void> saveTiposPagamento(List<TipoPagamentoModel> tipos) async {
    final db = await getDatabase();

    final batch = db.batch();
    batch.delete(tableTipoPagamento);

    for (var tipo in tipos) {
      batch.insert(
        tableTipoPagamento,
        tipo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<TipoPagamentoModel>> getTiposPagamento() async {
    final db = await getDatabase();
    final result = await db.query(tableTipoPagamento);

    return result.map((e) => TipoPagamentoModel.fromJson(e)).toList();
  }

  Future<void> saveCondicoesPagamento(
    List<CondicaoPagamentoModel> condicoes,
  ) async {
    final db = await getDatabase();

    final batch = db.batch();
    batch.delete(tableCondicaoPagamento);

    for (var condicao in condicoes) {
      batch.insert(
        tableCondicaoPagamento,
        condicao.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<CondicaoPagamentoModel>> getCondicoesPagamento() async {
    final db = await getDatabase();
    final result = await db.query(tableCondicaoPagamento);

    return result.map((e) => CondicaoPagamentoModel.fromJson(e)).toList();
  }
}
