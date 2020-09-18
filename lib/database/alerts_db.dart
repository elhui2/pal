import 'dart:async';
import 'dart:io';

import 'package:pal/models/alert.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

///
/// AlertsDb
/// @version 1.8
/// Comprueba en la base del dispositivo las alertas activas
///
class AlertsDb {
  AlertsDb._();

  static final AlertsDb db = AlertsDb._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "pal_sqlite.db");
    return await openDatabase(
      path,
      onCreate: (db, version) async {
        return db.execute(
          "CREATE TABLE alerts(id_alert INTEGER PRIMARY KEY AUTOINCREMENT, id_device TEXT, id_user INTEGER, status TEXT, type TEXT, register_date TEXT)",
        );
      },
      version: 1,
    );
  }

  newAlert(Alert newAlert) async {
    final db = await database;
    var res = await db.insert("alerts", newAlert.toSqlMap());
    return res;
  }

  updateAlert(Alert alert) async {
    final db = await database;
    var res = await db.update("alerts", alert.toSqlMap(),
        where: "id_alert = ?", whereArgs: [alert.idAlert]);
        print("alerts_db -> "+res.toString());
    return res;
  }

  ///
  /// getStatusAlert
  /// @version 1.1
  /// Obtiene alertas activas y por sincronizar(Prioridad)
  ///
  Future<Alert> getStatusAlert() async {
    final db = await database;
    var res = await db.rawQuery(
        "SELECT * FROM alerts WHERE status='sync' OR status='process' ORDER BY status DESC LIMIT 1");
    List<Alert> list =
        res.isNotEmpty ? res.map((c) => Alert.fromMap(c)).toList() : [];
    if (list.length > 0) {
      return list[0];
    } else {
      return null;
    }
  }

  deleteTable() async {
    final db = await database;
    db.rawDelete("DELETE FROM alerts WHERE status!='sync'");
  }
}
