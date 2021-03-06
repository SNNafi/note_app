import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_app/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'note_table';
  String colID = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colCreated = 'created';
  String colLastModified = 'last_modified';

  DatabaseHelper._createInstance(); //to create database instance

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await intializeDatabse();
    }

    return _database;
  }

  Future<Database> intializeDatabse() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + ' notes.db';

    var notesDB = await openDatabase(path, version: 1, onCreate: _createDB);
    return notesDB;
  }

  void _createDB(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colID INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,'
        '$colDescription TEXT, $colPriority INTEGER, $colCreated TEXT, $colLastModified TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;

    // var result = await db.rawQuery('SELECT * FROM $noteTable ORDER BY $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(Note note) async {
    Database db = await database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    var db = await database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colID = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async {
    var db = await database;
    var result =
        await db.rawDelete('DELETE FROM $noteTable WHERE $colID = $id');
    return result;
  }

  Future<int> getCount() async {
    var db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $noteTable');

    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();

    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}
