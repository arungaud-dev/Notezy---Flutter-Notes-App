import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notes_app/data/models/local_data_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  DBHelper._internal();

  static final String tableName = "notes";
  static final String column1 = "title";
  static final String column2 = "body";
  static final String column3 = "createdAt";
  static final String column4 = "updatedAt";
  static final String column5 = "isStar";
  static final String column6 = "category";

  static Database? db;

  Future<Database> get database async {
    if (db != null) return db!;
    db = await openDatabase(join(await getDatabasesPath(), "myDB.db"),
        version: 1, onCreate: (db, version) async {
      await db.execute("""
      CREATE table $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT,
      $column1 TEXT NOT NULL,
      $column2 TEXT NOT NULL,
      $column3 TEXT NOT NULL,
      $column4 TEXT,
      $column5 INTEGER,
      $column6 TEXT NOT NULL)
      """);
    });
    return db!;
  }

  //INSERT DATA
  Future<void> insertData(DataModel data) async {
    final db = await database;
    await db.insert(tableName, data.toMap());
  }

//GET DATA
  Future<List<DataModel>> getData() async {
    final db = await database;
    final data = await db.query(tableName);
    return data.map((e) => DataModel.fromMap(e)).toList();
  }

  //DELETE DATA
  Future<void> deleteData(int id) async {
    final db = await database;
    await db.delete(tableName, where: "id=?", whereArgs: [id]);
  }

  Future<void> updateData(int id, DataModel data) async {
    final db = await database;
    await db.update(tableName, data.toMap(), where: "id=?", whereArgs: [id]);
  }
}
