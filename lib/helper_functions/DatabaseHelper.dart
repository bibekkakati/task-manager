import '../models/Task.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //singleton
  static Database _database; //singleton

  String currentTable = 'current_table';
  String completedTable = 'completed_table';
  String colId = 'id';
  String colTaskName = 'taskName';
  String colDescription = 'description';
  String colAudioDescription = 'audioDescription';
  String colDate = 'date';
  String colTime = 'time';
  String colTimestamp = 'timestamp';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'tasks.db';

    var taskDatabase =
        await openDatabase(path, version: 1, onCreate: _createTables);
    return taskDatabase;
  }

  void _createTables(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $currentTable($colId TEXT PRIMARY KEY, $colTaskName TEXT, $colDescription TEXT, $colAudioDescription INTEGER, $colDate TEXT, $colTime TEXT,  $colTimestamp INTEGER )");
    await db.execute(
        "CREATE TABLE $completedTable($colId TEXT PRIMARY KEY, $colTaskName TEXT, $colDescription TEXT, $colAudioDescription INTEGER, $colDate TEXT, $colTime TEXT,  $colTimestamp INTEGER )");
  }

  Future<List<Map<String, dynamic>>> getCurrentTaskMapList() async {
    Database db = await this.database;
    var result = await db.query(currentTable, orderBy: '$colTimestamp ASC');
    return result;
  }

  Future<List<Task>> getCurrentTask(String id) async {
    Database db = await this.database;
    var result =
        await db.rawQuery('SELECT * FROM $currentTable WHERE $colId = ?', [id]);
    List<Task> taskList = [];
    if (result.length > 0) {
      taskList.add(Task.fromMapObject(result[0]));
    } else {
      result = await db
          .rawQuery('SELECT * FROM $completedTable WHERE $colId = ?', [id]);
      if (result.length > 0) {
        taskList.add(Task.fromMapObject(result[0]));
      }
    }
    return taskList;
  }

  Future<List<Map<String, dynamic>>> getCompletedTaskMapList() async {
    Database db = await this.database;
    var result = await db.query(completedTable, orderBy: '$colTimestamp DESC');
    return result;
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.database;
    var result = await db.insert(currentTable, task.toMap());
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.database;
    var result = await db.update(currentTable, task.toMap(),
        where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  Future<int> deleteCurrentTask(Task task) async {
    Database db = await this.database;
    var result = await db
        .rawDelete('DELETE FROM $currentTable WHERE $colId = ?', [task.id]);
    return result;
  }

  Future<int> deleteCompletedTask(Task task) async {
    Database db = await this.database;
    var result = await db
        .rawDelete('DELETE FROM $completedTable WHERE $colId = ?', [task.id]);
    return result;
  }

  Future<int> completeTask(Task task) async {
    Database db = await this.database;
    int q;
    await db.transaction((txn) async {
      q = await txn.insert(completedTable, task.toMap());
      q = await txn
          .rawDelete('DELETE FROM $currentTable WHERE $colId = ?', [task.id]);
    });
    return q;
  }

  Future<int> undoCompleteTask(Task task) async {
    Database db = await this.database;
    int q;
    await db.transaction((txn) async {
      q = await txn.insert(currentTable, task.toMap());
      q = await txn
          .rawDelete('DELETE FROM $completedTable WHERE $colId = ?', [task.id]);
    });
    return q;
  }

  Future<int> getCountCurrent() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT(*) FROM $currentTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getCountCompleted() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT(*) FROM $completedTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Task>> getCurrentTaskObjectList() async {
    var taskMapList = await getCurrentTaskMapList();
    int count = taskMapList.length;

    List<Task> taskList = List<Task>();
    for (var i = 0; i < count; i++) {
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }
    return taskList;
  }

  Future<List<Task>> getCompletedTaskObjectList() async {
    var taskMapList = await getCompletedTaskMapList();
    int count = taskMapList.length;

    List<Task> taskList = List<Task>();
    for (var i = 0; i < count; i++) {
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }
    return taskList;
  }
}
