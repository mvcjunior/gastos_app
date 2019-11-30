import 'dart:async';
import 'database.dart';
import 'package:sqflite/sqflite.dart';

class FormaPagamentoDatabase {
  final database = createDatabase();

  Future<void> insertFormaPagamento(FormaPagamento formaPagamento) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'forma_pagamento',
      formaPagamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FormaPagamento>> formaPagamentoFuture() async {
    // Get a reference to the database.
    Database db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('forma_pagamento', orderBy: 'descricao_forma_pagamento');
    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}

    return List.generate(maps.length, (i) {
      return FormaPagamento(
        id: maps[i]['id'],
        descricaoFormaPagamento: maps[i]['descricao_forma_pagamento'],
        tipo: maps[i]['tipo'],
        diaPagamento: maps[i]['dia_pagamento'],
        melhorData: maps[i]['melhor_data'],

      );
    });
  }

  Future<List<FormaPagamento>> formaPagamentoBackup() async {

    return await formaPagamentoFuture();
  }


  Future<bool> existeDescricaoFormaPagamento(FormaPagamento formaPagamento) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('forma_pagamento',
        orderBy: 'descricao_forma_pagamento',
        where: 'descricao_forma_pagamento = ? AND id != ?',
        whereArgs: [formaPagamento.descricaoFormaPagamento, formaPagamento.id != null ? formaPagamento.id : '']
    );
    return maps.length > 0;
  }
  Future<void> updateFormaPagamento(FormaPagamento formaPagamento) async {
    // Get a reference to the database.
    final db = await database;
    // Update the given Dog.
    await db.update(
      'forma_pagamento',
      formaPagamento.toMap(),
      where: "id = ?",
      whereArgs: [formaPagamento.id],
    );
  }

  Future<void> deleteFormaPagamento(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'forma_pagamento',
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
    await db.delete('forma_pagamento');
  }
}

class FormaPagamento {
  final int id;
  final String descricaoFormaPagamento;
  final String tipo;
  final int diaPagamento;
  final int melhorData;
  FormaPagamento({this.id, this.descricaoFormaPagamento, this.tipo, this.diaPagamento, this.melhorData});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao_forma_pagamento': descricaoFormaPagamento,
      'tipo': tipo,
      'dia_pagamento': diaPagamento,
      'melhor_data': melhorData,
    };
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'FormaPagamento {id: $id, descricaoFormaPagamento: $descricaoFormaPagamento, tipo: $tipo, '
        'diaPagamento: $diaPagamento, melhorData: $melhorData }';
  }

  FormaPagamento.fromMappedJson(Map<String, dynamic> json)
      : id = json['id'],
        descricaoFormaPagamento = json['descricao_forma_pagamento'],
        tipo = json['tipo'],
        diaPagamento = json['dia_pagamento'],
        melhorData = json['melhor_data'];

  String toJson() {
    return 'FormaPagamento: {"id": $id, "descricao_forma_pagamento": "$descricaoFormaPagamento", "tipo": "$tipo",'
        '"dia_pagamento": $diaPagamento, "melhor_data": $melhorData }';

  }

}
