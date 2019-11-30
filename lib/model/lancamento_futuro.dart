import 'dart:async';
import 'package:gastos/model/forma_pagamento.dart';
import 'package:gastos/utils/utils.dart';

import 'database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gastos/bottom_menu/resumo_categoria.dart';
import 'package:gastos/bottom_menu/grafico_mensal.dart';
import 'package:gastos/model/lancamento.dart';


class LancamentoFuturoDatabase {
  static final database = createDatabase();

  static Future<void> insertLancamentoFuturo(LancamentoFuturo lancamento) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'lancamentos_futuros',
      lancamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<LancamentoFuturo>> lancamentosFuturos() async {
    // Get a reference to the database.
    Database db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT  l.id, l.id_lancamento, l.id_sub_categoria, '
        'l.id_forma_pagamento, l.data, l.valor, s.descricao_sub_categoria, f.descricao_forma_pagamento, s.id_categoria, '
        'c.descricao_categoria, l.parcela '
        'FROM lancamentos_futuros AS l '
        'JOIN sub_categoria AS s ON s.id = l.id_sub_categoria '
        'JOIN categoria AS c ON c.id = s.id_categoria '
        'JOIN forma_pagamento AS f ON f.id = l.id_forma_pagamento '
        'ORDER BY l.data desc, s.descricao_sub_categoria');

    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}

    return List.generate(maps.length, (i) {
      return LancamentoFuturo(
        id: maps[i]['id'],
        idLancamento: maps[i]['id_lancamento'],
        idSubCategoria: maps[i]['id_sub_categoria'],
        descricaoSubCategoria: maps[i]['descricao_sub_categoria'],
        idCategoria: maps[i]['id_categoria'],
        descricaoCategoria: maps[i]['descricao_categoria'],
        data: maps[i]['data'],
        idFormaPagamento: maps[i]['id_forma_pagamento'],
        descricaoFormaPagamento: maps[i]['descricao_forma_pagamento'],
        valor: maps[i]['valor'],
        parcela: maps[i]['parcela'],
      );
    });
  }

  static Future<List<LancamentoFuturoResumo>> lancamentosResumo() async {
    // Get a reference to the database.
    Database db = await database;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT l.id_sub_categoria, "
        "strftime('%m/%Y',DATETIME(ROUND(l.data / 1000), 'unixepoch')) AS mes_ano, "
        'l.valor, f.descricao_forma_pagamento, l.id_forma_pagamento,  '
        's.descricao_sub_categoria, s.id_categoria, c.descricao_categoria '
        'FROM lancamentos_futuros AS l '
        'JOIN sub_categoria AS s ON s.id = l.id_sub_categoria '
        'JOIN categoria AS c ON c.id = s.id_categoria '
        'JOIN forma_pagamento AS f ON f.id = l.id_forma_pagamento '
        "ORDER BY strftime('%Y%m',DATETIME(ROUND(l.data / 1000), 'unixepoch')), "
        "f.descricao_forma_pagamento, l.valor ");

    // query(String table, {bool distinct, List<String> columns, String where, List<dynamic> whereArgs, String groupBy, String having, String orderBy, int limit, int offset}
    return List.generate(maps.length, (i) {
      return LancamentoFuturoResumo(
        idSubCategoria: maps[i]['id_sub_categoria'],
        idFormaPagamento: maps[i]['id_forma_pagamento'],
        descricaoFormaPagamento: maps[i]['descricao_forma_pagamento'],
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
        //"WHERE  strftime('%m%Y',DATETIME(ROUND(l.data / 1000), 'unixepoch')) == $mesAno "
        "GROUP BY strftime('%m%Y',DATETIME(ROUND(l.data / 1000), 'unixepoch')), s.id_categoria");
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


  static Future<List<LancamentoFuturo>> lancamentosBackup() async {

    return await lancamentosFuturos();
  }


  static Future<void> deleteLancamento(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'lancamentos_futuros',
      // Use a `where` clause to delete a specific dog.
      where: "id_lancamento = ?",
      whereArgs: [id],
    );
  }

  static Future<void> deleteAll() async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete('lancamentos_futuros');
  }

  static Future<void> parcelas(Lancamento lancamento, FormaPagamento formaPagamento, int id) async {
    // Get a reference to the database.
    final Database db = await database;

    List<int> datas = Utils.defineDatasLancamentosFuturos(lancamento.data, formaPagamento.diaPagamento,
        formaPagamento.melhorData, lancamento.quantidadeParcelas);
    int valor = Utils.defineValorLancamentosFuturos(lancamento.valor, lancamento.quantidadeParcelas);
    for (int i = 0; i < datas.length; i++) {

      await db.insert(
        'lancamentos_futuros',
        LancamentoFuturo(idLancamento: id,
            idSubCategoria: lancamento.idSubCategoria,
            data: datas[i],
            idFormaPagamento: lancamento.idFormaPagamento,
            parcela: i+1,
            valor: valor).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

  }
}


class LancamentoFuturo {
  final int id;
  final int idLancamento;
  final int idSubCategoria;
  final String descricaoSubCategoria;
  final int idCategoria;
  final String descricaoCategoria;
  final int data;
  final int idFormaPagamento;
  final String descricaoFormaPagamento;
  final int valor;
  final int parcela;

  LancamentoFuturo({this.id, this.idLancamento, this.idSubCategoria, this.data, this.idFormaPagamento, this.valor,
    this.descricaoSubCategoria, this.descricaoFormaPagamento, this.idCategoria, this.descricaoCategoria,
    this.parcela});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_lancamento': idLancamento,
      'id_sub_categoria': idSubCategoria,
      'id_forma_pagamento': idFormaPagamento,
      'data': data,
      'valor': valor,
      'parcela': parcela,
    };
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'LancamentoFuturo {id: $id, idLancamento: $idLancamento,  idSubCategoria: $idSubCategoria, '
        'decricaoSubCategoria: $descricaoSubCategoria, idFormaPagamento: $idFormaPagamento, descricaoFormaPagamento: '
        '$descricaoFormaPagamento, data: $data, valor: $valor, idCategoria: $idCategoria, descricaoCategoria: '
        '$descricaoCategoria, parcela: $parcela }';
  }

  LancamentoFuturo.fromMappedJson(Map<String, dynamic> json)
      : id = json['id'],
        idLancamento = json['id_lancamento'],
        idSubCategoria = json['id_sub_categoria'],
        idFormaPagamento = json['id_forma_pagamento'],
        data = json['data'],
        valor = json['valor'],
        descricaoFormaPagamento = json['descricao_forma_pagamento'],
        descricaoSubCategoria = json['descricao_sub_categoria'],
        idCategoria = json['id_categoria'],
        descricaoCategoria = json['descricao_categoria'],
        parcela = json['parcela'];


  String toJson() {
    return 'LancamentoFuturo: {"id": $id, "id_lancamento": $idLancamento, "id_sub_categoria": $idSubCategoria, '
        '"id_forma_pagamento": $idFormaPagamento, "data": $data, "valor": $valor, "parcela": $parcela }';

  }

}class LancamentoFuturoResumo {
  final int idSubCategoria;
  final String descricaoSubCategoria;
  final int idCategoria;
  final String descricaoCategoria;
  final String mesAno;
  final int idFormaPagamento;
  final String descricaoFormaPagamento;
  final int valor;

  LancamentoFuturoResumo({this.idSubCategoria, this.mesAno, this.idFormaPagamento, this.valor,
    this.descricaoSubCategoria, this.descricaoFormaPagamento, this.idCategoria, this.descricaoCategoria});


  @override
  String toString() {
    // TODO: implement toString
    return 'LancamentoFuturoResumo {idSubCategoria: $idSubCategoria, decricaoSubCategoria: $descricaoSubCategoria, '
        'idFormaPagamento: $idFormaPagamento, descricaoFormaPagamento: $descricaoFormaPagamento, '
        'mesAno: $mesAno, valor: $valor, idCategoria: $idCategoria, descricaoCategoria: $descricaoCategoria }';
  }

}

