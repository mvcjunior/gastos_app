import 'dart:async';
import 'database.dart';
import 'package:sqflite/sqflite.dart';

class NotificacaoDatabase {
  final database = createDatabase();

  Future<void> insert(Notificacao notificacao) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'notificacao',
      notificacao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Notificacao>> lista() async {
    // Get a reference to the database.
    Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('notificacao', orderBy: 'time_stamp');
    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}

    return List.generate(maps.length, (i) {
      return Notificacao(
        id: maps[i]['id'],
        package: maps[i]['package'],
        message: maps[i]['message'],
        timeStamp: maps[i]['time_stamp'],
      );
    });
  }

  Future<List<Notificacao>> notificaoBackup() async {

    return await lista();
  }


  Future<void> update(Notificacao notificao) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'notificao',
      notificao.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [notificao.id],
    );
  }

  Future<void> delete(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'notificao',
      // Use a `where` clause to delete a specific dog.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'notificao');
  }
}

class Notificacao {
  final int id;
  final String package;
  final String message;
  final String timeStamp;
  Notificacao({this.id, this.package, this.message, this.timeStamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'package': package,
      'message': message,
      'time_stamp': timeStamp,

    };
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'Notificacao {id: $id, package: $package, message: $message, "time_stamp": "$timeStamp"  }';
  }

  Notificacao.fromMappedJson(Map<String, dynamic> json)
      : id = json['id'],
        package = json['package'],
        message = json['message'],
        timeStamp = json['time_stamp'];

  String toJson() {
    return 'Notificacao: {"id": $id, "package": "$package", "message": "$message", "time_stamp": "$timeStamp" }';

  }
}

