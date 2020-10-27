import 'dart:io';

import 'package:lista_de_compras/src/model/item_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:async';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String comprasTable = 'compras_table';
  String colId = 'id';
  String colNameProduct = 'nameProduct';
  String colAmount = 'amount';
  String colType = 'type';
  String colDate = 'date';
  String colPrice = 'price';

  DatabaseHelper._createInstancia();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstancia();
    }
    return _databaseHelper;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $comprasTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$colNameProduct TEXT,$colAmount INTEGER, $colType TEXT, $colDate TEXT, '
        '$colPrice REAL);');
  }

  Future<Database> initializeDatabase() async {
    Directory diretorio = await getApplicationDocumentsDirectory();
    String path = diretorio.path + 'list_item.db';
    var itensDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return itensDatabase;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  // get all itens do banco
  Future<List<Map<String, dynamic>>> getItemMapList() async {
    Database db = await this.database;
    var result = await db.query(comprasTable, orderBy: '$colId ASC');
    return result;
  }

  // Add no banco
  Future<int> insertProduct(ItemList item) async {
    Database db = await this.database;
    var result = await db.insert(comprasTable, item.toMap());
    return result;
  }

  // Update banco
  Future<int> updateProduct(ItemList item) async {
    var db = await this.database;
    var result = await db.update(comprasTable, item.toMap(),
        where: '$colId = ?', whereArgs: [item.id]);
    return result;
  }

  // Delete do banco
  Future<int> deleteProduct(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $comprasTable WHERE $colId = $id');
    return result;
  }

  // Quantos itens existem no banco
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $comprasTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //Get total de valores
  Future<List<Map<String, dynamic>>> getAllTotalPurchases() async {
    Database db = await this.database;
    var result = db.rawQuery("SELECT SUM($colPrice) as total FROM $comprasTable");
    
    return result;
  }
  

  // Get todos elementos
  Future<List<ItemList>> getItensList() async {
    var itemMapList = await getItemMapList();
    int count = itemMapList.length;
    List<ItemList> itemList = List<ItemList>();
    for (int i = 0; i < count; i++) {
      itemList.add(ItemList.fromMapObject(itemMapList[i]));
    }
    return itemList;
  }
}
