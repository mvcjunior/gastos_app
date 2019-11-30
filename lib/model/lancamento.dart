import 'dart:async';
import 'package:gastos/model/forma_pagamento.dart';
import 'package:gastos/utils/utils.dart';

import 'database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gastos/bottom_menu/resumo_categoria.dart';
import 'package:gastos/bottom_menu/grafico_mensal.dart';
import 'package:gastos/model/lancamento_futuro.dart';

class LancamentoDatabase {
  static final database = createDatabase();

  Future<int> insertLancamento(Lancamento lancamento) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    return await db.insert(
      'lancamentos',
      lancamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insert(Lancamento lancamento, FormaPagamento formaPagamento) async {
    // Get a reference to the database.

    insertLancamento(lancamento)
      .then((id) {
        if ((formaPagamento != null && formaPagamento.tipo == Utils.credito()) ||
            (lancamento.quantidadeParcelas != null && lancamento.quantidadeParcelas > 1)) {
          LancamentoFuturoDatabase.parcelas(lancamento, formaPagamento, id);
        }
    });

  }

  Future<List<Lancamento>> lancamentosFuture() async {
    // Get a reference to the database.
    Database db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT  l.id, l.id_sub_categoria, l.id_forma_pagamento, '
        'l.data, l.valor, s.descricao_sub_categoria, f.descricao_forma_pagamento, s.id_categoria, c.descricao_categoria,'
        'l.parcelado, l.quantidade_parcelas '
        'FROM lancamentos AS l '
        'JOIN sub_categoria AS s ON s.id = l.id_sub_categoria '
        'JOIN categoria AS c ON c.id = s.id_categoria '
        'JOIN forma_pagamento AS f ON f.id = l.id_forma_pagamento '
        'ORDER BY l.data desc, s.descricao_sub_categoria');

    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}

    return List.generate(maps.length, (i) {
      return Lancamento(
        id: maps[i]['id'],
        idSubCategoria: maps[i]['id_sub_categoria'],
        descricaoSubCategoria: maps[i]['descricao_sub_categoria'],
        idCategoria: maps[i]['id_categoria'],
        descricaoCategoria: maps[i]['descricao_categoria'],
        data: maps[i]['data'],
        idFormaPagamento: maps[i]['id_forma_pagamento'],
        descricaoFormaPagamento: maps[i]['descricao_forma_pagamento'],
        valor: maps[i]['valor'],
        quantidadeParcelas: maps[i]['quantidade_parcelas'],
        parcelado: maps[i]['parcelado'],
      );
    });
  }

  Future<List<LancamentoResumo>> lancamentosResumo() async {
    // Get a reference to the database.
    Database db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT l.id_sub_categoria, "
        "strftime('%m/%Y',DATETIME(ROUND(l.data / 1000), 'unixepoch')) AS mes_ano, "
        'SUM(l.valor) as valor, '
        's.descricao_sub_categoria, s.id_categoria, c.descricao_categoria '
        'FROM lancamentos AS l '
        'JOIN sub_categoria AS s ON s.id = l.id_sub_categoria '
        'JOIN categoria AS c ON c.id = s.id_categoria '
        "GROUP BY l.id_sub_categoria, strftime('%Y%m',DATETIME(ROUND(l.data / 1000), 'unixepoch')) "
        "ORDER BY strftime('%Y%m',DATETIME(ROUND(l.data / 1000), 'unixepoch')) desc, c.descricao_categoria, s.descricao_sub_categoria ");

    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}
    return List.generate(maps.length, (i) {
      return LancamentoResumo(
        idSubCategoria: maps[i]['id_sub_categoria'],
        descricaoSubCategoria: maps[i]['descricao_sub_categoria'],
        idCategoria: maps[i]['id_categoria'],
        descricaoCategoria: maps[i]['descricao_categoria'],
        mesAno: maps[i]['mes_ano'],
        valor: maps[i]['valor'],
      );
    });
  }

  Future<List<GastosCategoria>> resumoCategoriaAnoMes(ResumoMesAno resumo) async {
    // Get a reference to the database.
    Database db = await database;
    String mesAno = resumo.mesAno.replaceAll('/', '');
    final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT "
        'SUM(l.valor) as valor, s.id_categoria, c.descricao_categoria, '
        "strftime('%m%Y',DATETIME(ROUND(l.data / 1000), 'unixepoch')) as mes_ano "
        'FROM lancamentos AS l '
        'JOIN categoria AS c ON c.id = s.id_categoria '
        'JOIN sub_categoria AS s ON s.id = l.id_sub_categoria '
        "GROUP BY strftime('%m%Y',DATETIME(ROUND(l.data / 1000), 'unixepoch')), s.id_categoria "
        'ORDER BY l.valor desc');
    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}

    List<GastosCategoria> lista = List();
    maps.forEach((m){
      if (mesAno == m['mes_ano']) {
          lista.add(GastosCategoria(
            descricaoCategoria: m['descricao_categoria'],
            valor: m['valor'],
          ));

      }
    });
    return lista;
  }


  Future<List<ResumoMesAno>> resumoAnoMes() async {
    // Get a reference to the database.
    Database db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT "
        "strftime('%m/%Y',DATETIME(ROUND(l.data / 1000), 'unixepoch')) AS mes_ano "
        'FROM lancamentos AS l '
        "GROUP BY strftime('%Y%m',DATETIME(ROUND(l.data / 1000), 'unixepoch')) "
        "ORDER BY strftime('%Y%m',DATETIME(ROUND(l.data / 1000), 'unixepoch')) desc ");

    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}
    return List.generate(maps.length, (i) {
      return ResumoMesAno(maps[i]['mes_ano'], null);
    });
  }


  Future<List<Lancamento>> lancamentosBackup() async {

    return await lancamentosFuture();
  }


  Future<void> updateLancamento(Lancamento lancamento, FormaPagamento formaPagamento) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'lancamentos',
      lancamento.toMap(),
      where: "id = ?",
      whereArgs: [lancamento.id],
    );
    await LancamentoFuturoDatabase.deleteLancamento(lancamento.id);

    if ((formaPagamento != null && formaPagamento.tipo == Utils.credito()) ||
        (lancamento.quantidadeParcelas != null && lancamento.quantidadeParcelas > 1)) {
      LancamentoFuturoDatabase.parcelas(lancamento, formaPagamento, lancamento.id);
    }
  }

  Future<void> deleteLancamento(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'lancamentos',
      // Use a `where` clause to delete a specific dog.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );

    await LancamentoFuturoDatabase.deleteLancamento(id);
  }

  Future<void> deleteAll() async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete('lancamentos');
  }
}


class Lancamento {
  final int id;
  final int idSubCategoria;
  final String descricaoSubCategoria;
  final int idCategoria;
  final String descricaoCategoria;
  final int data;
  final int idFormaPagamento;
  final String descricaoFormaPagamento;
  final int valor;
  final String parcelado;
  final int quantidadeParcelas;

  Lancamento({this.id, this.idSubCategoria, this.data, this.idFormaPagamento, this.valor,
    this.descricaoSubCategoria, this.descricaoFormaPagamento, this.idCategoria, this.descricaoCategoria,
    this.parcelado, this.quantidadeParcelas});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_sub_categoria': idSubCategoria,
      'id_forma_pagamento': idFormaPagamento,
      'data': data,
      'valor': valor,
      'parcelado': parcelado,
      'quantidade_parcelas': quantidadeParcelas
    };
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'Lancamento {id: $id, idSubCategoria: $idSubCategoria, decricaoSubCategoria: $descricaoSubCategoria, '
        'idFormaPagamento: $idFormaPagamento, descricaoFormaPagamento: $descricaoFormaPagamento, '
        'data: $data, valor: $valor, idCategoria: $idCategoria, descricaoCategoria: $descricaoCategoria, '
        'parcelado: $parcelado, quantidadeParcelas: $quantidadeParcelas }';
  }

  Lancamento.fromMappedJson(Map<String, dynamic> json)
      : id = json['id'],
        idSubCategoria = json['id_sub_categoria'],
        idFormaPagamento = json['id_forma_pagamento'],
        data = json['data'],
        valor = json['valor'],
        descricaoFormaPagamento = json['descricao_forma_pagamento'],
        descricaoSubCategoria = json['descricao_sub_categoria'],
        idCategoria = json['id_categoria'],
        descricaoCategoria = json['descricao_categoria'],
        parcelado = json['parcelado'],
        quantidadeParcelas = json['quantidade_parcelas'];


  String toJson() {
    return 'Lancamento: {"id": $id, "id_sub_categoria": $idSubCategoria, "id_forma_pagamento": $idFormaPagamento, '
        '"data": $data, "valor": $valor, "parcelado": "$parcelado", "quantidade_parcelas": $quantidadeParcelas }';

  }

}

class LancamentoResumo {
  final int idSubCategoria;
  final String descricaoSubCategoria;
  final int idCategoria;
  final String descricaoCategoria;
  final String mesAno;
  final int idFormaPagamento;
  final String descricaoFormaPagamento;
  final int valor;

  LancamentoResumo({this.idSubCategoria, this.mesAno, this.idFormaPagamento, this.valor,
    this.descricaoSubCategoria, this.descricaoFormaPagamento, this.idCategoria, this.descricaoCategoria});


  @override
  String toString() {
    // TODO: implement toString
    return 'LancamentoResumo {idSubCategoria: $idSubCategoria, decricaoSubCategoria: $descricaoSubCategoria, '
        'idFormaPagamento: $idFormaPagamento, descricaoFormaPagamento: $descricaoFormaPagamento, '
        'mesAno: $mesAno, valor: $valor, idCategoria: $idCategoria, descricaoCategoria: $descricaoCategoria }';
  }

}

