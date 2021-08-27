import 'dart:async';
import 'dart:io';
import 'package:notekeeper/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton Database Helper
  static Database _database; // Singelton Database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); // Named constructor instance of DatabaseHelper
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await intializeDatabase();
    }
    return _database;
  }

  Future<Database> intializeDatabase() async {
    // Get the directory path for both Android and IOS to store Database
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'notes.db');
    // Open/ create the database at the given path
    var noteDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return noteDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDescription TEXT,$colPriority INTEGER,$colDate TEXT)');
  }

// Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    //var result=await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy:colPriority);
    return result;
  }

// Insert Operation: Insert a Note Object to database
  Future<int> inserNote(Note note) async {
    var db = await this.database;
    int result = await db.insert(noteTable, note.toMap());
    return result;
  }

// Update Operation: Delete a NoteObject from database
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId=?', whereArgs: [note.id]);
    return result;
  }

// Delete Operation: Delete a NoteObject from database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId=$id');
    return result;
  }

// Get number of Note Objects in database

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT(*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteList = await getNoteMapList();
    int count = noteList.length;

    List<Note> note = [];

    for (int i = 0; i < count; i++) {
      note.add(Note.fromMapObject(noteList[i]));
    }
    return note;
  }
}
