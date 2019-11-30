import 'dart:async';
import 'database.dart';
import 'package:sqflite/sqflite.dart';

class SubCategoriaDatabase {
  final database = createDatabase();

  Future<void> insertSubCategoria(SubCategoria subCategoria) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'sub_categoria',
      subCategoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SubCategoria>> subCategoriasFuture() async {
    // Get a reference to the database.
    Database db = await database;

    // Query the table for all The Dogs.
    //final List<Map<String, dynamic>> maps = await db.query('sub_categoria', orderBy: 'descricao_sub_categoria');
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT  s.id, s.descricao_sub_categoria, s.id_categoria, c.descricao_categoria  '
        'FROM sub_categoria AS s JOIN categoria  AS c '
        'WHERE s.id_categoria = c.id ORDER BY c.descricao_categoria, s.descricao_sub_categoria');
    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}

    return List.generate(maps.length, (i) {
      return SubCategoria(
        id: maps[i]['id'],
        descricaoSubCategoria: maps[i]['descricao_sub_categoria'],
        idCategoria: maps[i]['id_categoria'],
        descricaoCategoria: maps[i]['descricao_categoria'],
      );
    });
  }

  Future<List<SubCategoria>> subCategoriasBackup() async {

    return await subCategoriasFuture();
  }


  Future<List<SubCategoria>> subCategoriasDeCategoriaFuture(int idCategoria) async {
    // Get a reference to the database.
    Database db = await database;

    // Query the table for all The Dogs.
    //final List<Map<String, dynamic>> maps = await db.query('sub_categoria', orderBy: 'descricao_sub_categoria');
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT  s.id, s.descricao_sub_categoria, s.id_categoria, c.descricao_categoria  '
        'FROM sub_categoria AS s JOIN categoria  AS c '
        'WHERE s.id_categoria = c.id AND s.id_categoria = ${idCategoria} '
        'ORDER BY c.descricao_categoria, s.descricao_sub_categoria');
    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}

    return List.generate(maps.length, (i) {
      return SubCategoria(
        id: maps[i]['id'],
        descricaoSubCategoria: maps[i]['descricao_sub_categoria'],
        idCategoria: maps[i]['id_categoria'],
        descricaoCategoria: maps[i]['descricao_categoria'],
      );
    });
  }

  Future<void> updateSubCategoria(SubCategoria subCategoria) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'sub_categoria',
      subCategoria.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [subCategoria.id],
    );
  }

  Future<void> deleteSubCategoria(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'sub_categoria',
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
      'sub_categoria');
  }
}

class SubCategoria {
  final int id;
  final String descricaoSubCategoria;
  final int idCategoria;
  final String descricaoCategoria;
  SubCategoria({this.id, this.descricaoSubCategoria, this.idCategoria, this.descricaoCategoria});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao_sub_categoria': descricaoSubCategoria,
      'id_categoria': idCategoria
    };
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'SubCategoria {id: $id, descricaoSubCategoria: $descricaoSubCategoria, idCategoria: $idCategoria  }';
  }

  SubCategoria.fromMappedJson(Map<String, dynamic> json)
      : id = json['id'],
        descricaoSubCategoria = json['descricao_sub_categoria'],
        idCategoria = json['id_categoria'],
        descricaoCategoria = json['descricao_categoria'];

  String toJson() {
    return 'SubCategoria: {"id": $id, "descricao_sub_categoria": "$descricaoSubCategoria", "id_categoria": $idCategoria }';

  }
}

