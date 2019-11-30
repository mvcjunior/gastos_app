import 'dart:io';
import 'package:gastos/model/lancamento_futuro.dart';

import '../model/categoria.dart';
import '../model/sub_categoria.dart';
import '../model/forma_pagamento.dart';
import '../model/lancamento.dart';
import 'dart:convert';


class Restore {
  static final String CATEGORIA = 'Categoria';
  static final String SUB_CATEGORIA = 'SubCategoria';
  static final String FORMA_PAGAMENTO = 'FormaPagamento';
  static final String LANCAMENTO = 'Lancamento:';
  static final String LANCAMENTO_FUTURO = 'LancamentoFuturo:';

  static Future<int> executa(String arquivo) async {
    print('RESTORE Inicio');
    print('RESTORE arquivo');

    var restore = File(arquivo);
    print('RESTORE $arquivo');

    List<Categoria> categorias = List();
    List<SubCategoria> subCategorias = List();
    List<FormaPagamento> formasPagamentos = List();
    List<Lancamento> lancamentos = List();
    List<LancamentoFuturo> lancamentosFuturos = List();
    print('RESTORE loop');

    restore.readAsLinesSync().forEach((f) {
      print('RESTORE $f');
        Map userMap = jsonDecode(f.substring(f.indexOf(':')+1));
        if (CATEGORIA == f.substring(0,CATEGORIA.length)) {
          categorias.add(Categoria.fromMappedJson(userMap));
        } else if (SUB_CATEGORIA == f.substring(0,SUB_CATEGORIA.length)) {
          subCategorias.add(SubCategoria.fromMappedJson(userMap));
        } else if (FORMA_PAGAMENTO == f.substring(0, FORMA_PAGAMENTO.length)) {
          formasPagamentos.add(FormaPagamento.fromMappedJson(userMap));
        } else if (LANCAMENTO == f.substring(0, LANCAMENTO.length)) {
          lancamentos.add(Lancamento.fromMappedJson(userMap));
        } else if (LANCAMENTO_FUTURO == f.substring(0, LANCAMENTO_FUTURO.length)) {
          lancamentosFuturos.add(LancamentoFuturo.fromMappedJson(userMap));
        }

    } );
    print('RESTORE Categoria');

    await CategoriaDatabase().deleteAll()
      .then((res) {
      for (Categoria categoria in categorias)
          CategoriaDatabase().insertCategoria(categoria);
    });
    print('RESTORE SubCategoria');

    await SubCategoriaDatabase().deleteAll()
        .then((res) {
      for (SubCategoria subCategoria in subCategorias)
            SubCategoriaDatabase().insertSubCategoria(subCategoria);
    });
    print('RESTORE FormaPagamento');

    await FormaPagamentoDatabase().deleteAll()
        .then((res) {
      for (FormaPagamento formaPagamento in formasPagamentos)
            FormaPagamentoDatabase().insertFormaPagamento(formaPagamento);
    });
    print('RESTORE Lancamento');

    await LancamentoDatabase().deleteAll()
        .then((res) {
      for (Lancamento lancamento in lancamentos) {
        LancamentoDatabase().insertLancamento(lancamento);
      }

    });
    print('RESTORE LancamentoFuturo');
    await LancamentoFuturoDatabase.deleteAll()
        .then((res) {
         for (LancamentoFuturo lancamentoFuturo in lancamentosFuturos) {
           LancamentoFuturoDatabase.insertLancamentoFuturo(lancamentoFuturo);
         }
    });
    print('RESTORE Fim');

    return 1;
  }

}


