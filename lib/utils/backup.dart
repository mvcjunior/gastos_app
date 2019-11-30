import 'dart:io';
import '../utils/utils.dart';
import '../model/categoria.dart';
import '../model/sub_categoria.dart';
import '../model/forma_pagamento.dart';
import '../model/lancamento.dart';
import '../model/lancamento_futuro.dart';


class Backup {
  static final String NOVA_LINHA = '\n';
  static Future<int> executa(String caminho) async {
    var backup = File(Utils.formataNomeArquivo(caminho));
    backup.createSync();
    backup.openSync(mode: FileMode.append);
    Future<List<Categoria>> categorias =  CategoriaDatabase().categoriasBackup();
    await categorias.then((categorias) {
      categorias.forEach((categoria) {
        backup.writeAsStringSync(categoria.toJson(), mode: FileMode.append);
        backup.writeAsStringSync(NOVA_LINHA, mode: FileMode.append);
      });
    }).catchError((onError) {

    });

    Future<List<SubCategoria>> subcategorias =  SubCategoriaDatabase().subCategoriasBackup();
    await subcategorias.then((subcategorias) {
      subcategorias.forEach((subcategoria) {
        backup.writeAsStringSync(subcategoria.toJson(), mode: FileMode.append);
        backup.writeAsStringSync(NOVA_LINHA, mode: FileMode.append);
      });
    }).catchError((onError) {

    });

    Future<List<FormaPagamento>> formaPagamentos =  FormaPagamentoDatabase().formaPagamentoBackup();
    await formaPagamentos.then((formaPagamento) {
      formaPagamento.forEach((formaPagamento) {
        backup.writeAsStringSync(formaPagamento.toJson(), mode: FileMode.append);
        backup.writeAsStringSync(NOVA_LINHA, mode: FileMode.append);
      });
    }).catchError((onError) {

    });

    Future<List<Lancamento>> lancamentos =  LancamentoDatabase().lancamentosFuture();
    await lancamentos.then((lancamento) {
      lancamento.forEach((lancamento) {
        backup.writeAsStringSync(lancamento.toJson(), mode: FileMode.append);
        backup.writeAsStringSync(NOVA_LINHA, mode: FileMode.append);
      });
    }).catchError((onError) {

    });

    Future<List<LancamentoFuturo>> lancamentosFututos =  LancamentoFuturoDatabase.lancamentosFuturos();
    await lancamentosFututos.then((lancamentosFuturo) {
      lancamentosFuturo.forEach((lancamentoFuturo) {
        backup.writeAsStringSync(lancamentoFuturo.toJson(), mode: FileMode.append);
        backup.writeAsStringSync(NOVA_LINHA, mode: FileMode.append);
      });
    }).catchError((onError) {

    });


    return 1;
  }
}


