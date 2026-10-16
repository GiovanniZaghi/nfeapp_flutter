import 'package:nfeapp_flutter/app/core/database/dao/cart/cart_dao.dart';
import 'package:nfeapp_flutter/app/core/database/dao/cart/payment_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dao/cart/custummer_dao.dart';
import 'dao/cart/product_dao.dart';

Future<Database> getDatabase() async {
  var databasesPath = await getDatabasesPath();
  final String path = join(databasesPath, 'prosystem.db');

  var db = await openDatabase(
    path,
    version: 5,
    onCreate: (db, version) async {
      await db.execute(CartDao.createTableCart);
      await db.execute(CartDao.createTableCartOrder);
      await db.execute(PaymentDao.createTableTipoPagamento);
      await db.execute(PaymentDao.createTableCondicaoPagamento);
      await db.execute(CustomerDao.createTableCustomer);
      await db.execute(ConsultProductDao.createTableConsultProduct);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      await db.execute(CartDao.createTableCart);
      await db.execute(CartDao.createTableCartOrder);
      await db.execute(PaymentDao.createTableTipoPagamento);
      await db.execute(PaymentDao.createTableCondicaoPagamento);
      await db.execute(CustomerDao.createTableCustomer);
      await db.execute(ConsultProductDao.createTableConsultProduct);
      await CartDao.migrateAddPedidoClienteETabela(db);
    },
  );
  return db;
}
