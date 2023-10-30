import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import 'package:sqlitedb/student.dart';

class DBManager {
  static Database? _db;
  static const String ID = 'controlNum';
  static const String NAME = 'name';
  static const String APEPA = 'apepa';
  static const String APEMA = 'apema';
  static const String TEL = 'tel';
  static const String EMAIL = 'email';
  static const String PHOTO_NAME = 'photo_name';
  static const String TABLE = 'Students';
  static const String DB_NAME = 'students.db';

  //InitDB
  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDB();
      return _db;
    }
  }

  initDB() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, "
        "$NAME TEXT, $APEPA TEXT, $APEMA TEXT, $TEL TEXT, "
        "$EMAIL TEXT, $PHOTO_NAME TEXT)");
  }

  //Insert
  Future<Student> save(Student student) async {
    var dbClient = await _db;
    student.controlNum = await dbClient!.insert(TABLE, student.toMap());
    return student;
  }

  //Select
  Future<List<Student>> getStudents() async {
    var dbClient = await (db);
    List<Map> maps = await dbClient!.query(TABLE,
        columns: [ID, NAME, APEPA, APEMA, TEL, EMAIL, PHOTO_NAME]);
    List<Student> students = [];
    print(students.length);
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        print("Datos");
        print(Student.fromMap(maps[i] as Map<String, dynamic>));
        students.add(Student.fromMap(maps[i] as Map<String, dynamic>));
      }
    }
    return students;
  }

  //Delete
  Future<int> delete(int id) async {
    var dbClient = await (db);
    return await dbClient!.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }
  //Update
  Future<int> update(Student student) async {
    var dbClient = await (db);
    return await dbClient!.update(TABLE, student.toMap(),
        where: '$ID = ?', whereArgs: [student.controlNum]);
  }
  //Close DB
  Future close() async {
    var dbClient = await (db);
    dbClient!.close();
  }
}
