/*

This snippet provides a simple example of how to
insert a record into a sql database, using sqlfite

MIT License

Copyright (c) 2020, Mark Seery

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

class DatabaseManager {
  static final columnId = '_id';
  static final columnListName = 'listName';
  static final columnListItemNumber = 'listNumber';
  static final columnListItemLabel = 'ListLabel';
  static final table = 'tableName';

  static final _databaseName = "test.db";
  static final _databaseVersion = 1;

  // make this a singleton class
  DatabaseManager._privateConstructor();
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Database db;

  DatabaseManager() {
    DatabaseManager db = DatabaseManager.instance;
    _dbexec();
  }

  Future<Database> get database async {
    //Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //print("Document directory: " + documentsDirectory.path);
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    db = await instance.database;
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  _dbexec() async {
    await _insertRow();
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnListName TEXT NOT NULL,
            $columnListItemNumber TEXT NOT NULL,
            $columnListItemLabel TEXT NOT NULL,
            unique ($columnListItemNumber)
          )
          ''');
  }

  _insertRow() async {
    Map<String, dynamic> row = {
      //DatabaseManager.columnId   : 1,
      DatabaseManager.columnListName: 'List Name',
      DatabaseManager.columnListItemNumber: "01",
      DatabaseManager.columnListItemLabel: "List Item",
    };
    await insert(row, table);
  }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row, String table) async {
    if (row != null) {
      Database db = await instance.database;
      int result = 0;
      try {
        result = await db.insert(table, row);
        print("successful insert: " + result.toString());
        return result;
      } catch (e) {
        //print(row.toString());
        print(e.toString());
        return -1;
      }
    }
    return -1;
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String updateTable) async {
    Database db = await instance.database;
    return await db.query(updateTable);
  }
}
