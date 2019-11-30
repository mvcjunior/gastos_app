import 'dart:async';
import 'database.dart';
import 'package:sqflite/sqflite.dart';

class CategoriaDatabase {
  final database = createDatabase();

   Future<void> insertCategoria(Categoria categoria) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'categoria',
      categoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Categoria>> categoriasFuture() async {
    // Get a reference to the database.
    Database db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('categoria', orderBy: 'descricao_categoria');
    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}

    return List.generate(maps.length, (i) {
      return Categoria(
        id: maps[i]['id'],
        descricaoCategoria: maps[i]['descricao_categoria'],
      );
    });
  }

  Future<List<Categoria>> categoriasBackup() async {

     return await categoriasFuture();
  }

   Future<void> updateCategoria(Categoria categoria) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'categoria',
      categoria.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [categoria.id],
    );
  }

   Future<bool> existeDescricaoCategoria(Categoria categoria) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categoria',
        orderBy: 'descricao_categoria',
        where: 'descricao_categoria = ? AND id != ?',
        whereArgs: [categoria.descricaoCategoria, categoria.id != null ? categoria.id : '']
    );
    return maps.length > 0;
  }
  Future<void> deleteCategoria(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'categoria',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete('categoria');
  }
}

class Categoria {
  final int id;
  final String descricaoCategoria;
  Categoria({this.id, this.descricaoCategoria});
  //Categoria(this.id, this.descricaoCategoria);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao_categoria': descricaoCategoria
    };
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'Categoria {"id": $id, "descricaoCategoria": $descricaoCategoria }';
  }

  Categoria.fromMappedJson(Map<String, dynamic> json)
      : id = json['id'],
        descricaoCategoria = json['descricao_categoria'];

  String toJson() {
    return 'Categoria: {"id": $id, "descricao_categoria": "$descricaoCategoria" }';

  }
}

