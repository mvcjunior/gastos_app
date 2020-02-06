import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


createDatabase() async {
  String databasesPath = await getDatabasesPath();
  String dbPath = join(databasesPath, 'gastos.db');
  var database = await openDatabase(dbPath, version: 4, onCreate: populateDb, onUpgrade: upgradeDb   );
  database.getVersion().then( (version) {
    print ('VERSÃO BANCO DE DADOS $version');
  });
  return database;
}

void populateDb(Database database, int version) async {
  await database.execute("CREATE TABLE categoria ("
      "id INTEGER PRIMARY KEY,"
      "descricao_categoria TEXT"
      ")");
  print('CRIEI categoria');
  await database.execute("INSERT INTO categoria "
      "(id, descricao_categoria) VALUES "
      "(1, 'Lazer'), (2, 'Casa'), (3, 'Pessoal')");
  print('INSERI categoria');

  await database.execute("CREATE TABLE sub_categoria ("
      "id INTEGER PRIMARY KEY,"
      "descricao_sub_categoria TEXT,"
      "id_categoria INTEGER"
      ")");
  print('CRIEI sub_categoria');

  await database.execute("INSERT INTO sub_categoria "
      "(id, descricao_sub_categoria, id_categoria ) VALUES "
      "(1, 'Estacionamento', 1), (2, 'Conveniencia', 1), (3, 'Restaurante', 1)");

  await database.execute("CREATE TABLE forma_pagamento ("
      "id INTEGER PRIMARY KEY, "
      "descricao_forma_pagamento TEXT, "
      "tipo TEXT, "
      "dia_pagamento INTEGER, "
      "melhor_data INTEGER"
      ")");
  print('CRIEI forma_pagamento');


  await database.execute("CREATE TABLE lancamentos ("
      "id INTEGER PRIMARY KEY, "
      "id_sub_categoria INTEGER, "
      "data INTEGER, "
      "valor INTEGER, "
      "id_forma_pagamento INTEGER, "
      "parcelado TEXT, "
      "quantidade_parcelas INTEGER"
      ")");
  print('CRIEI lancamentos');

  await database.execute("CREATE TABLE lancamentos_futuros ("
      "id INTEGER PRIMARY KEY, "
      "id_lancamento INTEGER, "
      "id_sub_categoria INTEGER, "
      "data INTEGER, "
      "valor INTEGER, "
      "id_forma_pagamento INTEGER, "
      "parcela INTEGER "
      ")");
  print('CRIEI lancamentos_futuros');

  await database.execute("CREATE TABLE notificacao ("
      "id INTEGER PRIMARY KEY, "
      "package TEXT, "
      "message TEXT, "
      "time_stamp TEXT "
      ")");
  print('CRIEI notificacoes');
}

void upgradeDb(Database database, int atual, int nova) async {
  print ('upgradeDb');
  print (atual);
  print (nova);
  await database.execute("CREATE TABLE notificacao ("
      "id INTEGER PRIMARY KEY, "
      "package TEXT, "
      "message TEXT, "
      "time_stamp TEXT "
      ")");
  print('CRIEI notificacoes');

}