import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notes_app/data/models/note_model.dart';

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
  static final String column7 = "isSynced";

  static Database? db;

  Future<Database> get database async {
    if (db != null) return db!;
    db = await openDatabase(join(await getDatabasesPath(), "myDB.db"),
        version: 1, onCreate: (db, version) async {
      await db.execute("""
      CREATE table $tableName(id TEXT NOT NULL PRIMARY KEY,
      $column1 TEXT NOT NULL,
      $column2 TEXT NOT NULL,
      $column3 TEXT NOT NULL,
      $column4 INTEGER,
      $column5 INTEGER,
      $column6 TEXT NOT NULL,
      $column7 INTEGER NOT NULL)
      """);

      await db.execute("""
      CREATE TABLE category(
      title TEXT PRIMARY KEY,
      color TEXT NOT NULL
      )
      """);
    });
    return db!;
  }

  //INSERT DATA
  Future<void> insertData(NoteModel data) async {
    try {
      final db = await database;
      await db.insert(tableName, data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint(
          "A ERROR ON DATA INSERTING PLEASE CHECK DATABASE FILE: ${e.toString()}");
    }
  }

//GET DATA
  Future<List<NoteModel>> getData() async {
    final db = await database;
    try {
      final data = await db.query(tableName, orderBy: "$column4 DESC");
      return data.map((e) => NoteModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("A ERROR ON DATA GETTING PLEASE CHECK DATABASE FILE");
      return [];
    }
  }

  //DELETE DATA
  Future<void> deleteData(String id) async {
    final db = await database;
    try {
      await db.delete(tableName, where: "id=?", whereArgs: [id]);
    } catch (e) {
      debugPrint("A ERROR ON DATA DELETING");
    }
  }

  Future<void> updateData(String id, NoteModel data) async {
    final db = await database;
    try {
      await db.update(tableName, data.toMap(), where: "id=?", whereArgs: [id]);
    } catch (e) {
      debugPrint("A ERROR ON DATA UPDATING");
    }
  }

  Future<List<NoteModel>> getUnSyncedData() async {
    final db = await database;
    try {
      final data =
          await db.query(tableName, where: "$column7=?", whereArgs: [0]);
      return data.map((e) => NoteModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("A ERROR ON DATA GETTING PLEASE CHECK DATABASE FILE");
      return [];
    }
  }

  Future<void> markSynced(String id) async {
    final db = await database;
    try {
      await db.update(tableName, {column7: 1}, where: "id=?", whereArgs: [id]);
    } catch (e) {
      debugPrint("A ERROR IN DATA SYNCED MARKING PLEASE CHECK SQL FILE");
    }
  }

//-------------------------------- CATEGORY FUNCTIONS ---------------------------

  Future<void> addCategory(Map<String, dynamic> data) async {
    final db = await database;
    try {
      await db.insert("category", data);
    } catch (e) {
      debugPrint("A ERROR ON CATEGORY ADD");
    }
  }

  Future<void> removeCategory(int id) async {
    final db = await database;
    try {
      await db.delete("category", where: "id=?", whereArgs: [id]);
    } catch (e) {
      debugPrint("A ERROR ON CATEGORY ADD");
    }
  }

  Future<List<Map<String, dynamic>>> getCategory() async {
    final db = await database;
    try {
      final data = await db.query("category");
      return data;
    } catch (e) {
      debugPrint("A ERROR ON GETTING CATEGORY: $e");
      return [];
    }
  }
}
