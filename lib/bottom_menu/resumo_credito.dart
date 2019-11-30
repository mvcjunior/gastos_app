import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos/menu/page_lancamento.dart';
import 'package:gastos/model/forma_pagamento.dart';
import 'package:gastos/model/categoria.dart';
import 'package:gastos/model/lancamento.dart';
import 'package:gastos/model/lancamento_futuro.dart';
import '../utils/utils.dart';

class ResumoCredito extends StatefulWidget {
  ResumoCredito({Key key}) : super(key: key);
  @override
  _ResumoCredito createState() => _ResumoCredito();
}


class _ResumoCredito extends State<ResumoCredito> {
  Future<List<ResumoMesAno>> _resumoLancamentoCategoria;


  @override
  void initState() {
    super.initState();
    _resumoLancamentoCategoria = geraItemsResumo();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _resumoLancamentoCategoria,
        builder: (context, lancamentosSnap) {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: lancamentosSnap.data != null ? lancamentosSnap.data.length : 0,
        itemBuilder: (context, index) {
          final ResumoMesAno item = lancamentosSnap.data[index];
            return ListTile(
                title: Card(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                              child: Text(
                                  Utils.formataMesAno(item.mesAno),
                                  style: TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: _listaItemsFormaPagamento(item.listaResumoAnoMesFormaPagamento),
                        )
                      ],
                    ),
                  ),
            )
            );
            },
          );
        },
      );
  }

  Future<List<ResumoMesAno>> geraItemsResumo() async {
    List<LancamentoFuturoResumo> lancamentosResumo = await LancamentoFuturoDatabase.lancamentosResumo();
    List<ResumoMesAno> listaResumo = List();
    String mesAno = '';
    ResumoMesAno resumo;
    List<LancamentoFuturoResumo> lancamentos;
    List<ResumoAnoMesFormaPagamento> listaResumoAnoMesCategoria;
    int totalFormaPagamento = 0;
    FormaPagamento formaPagamento = FormaPagamento(id: 0);
    lancamentosResumo.forEach((lancamento) {
      if (formaPagamento.descricaoFormaPagamento != lancamento.descricaoFormaPagamento && lancamento.mesAno == mesAno) {
        listaResumoAnoMesCategoria.add(ResumoAnoMesFormaPagamento(formaPagamento.id,
            formaPagamento.descricaoFormaPagamento, totalFormaPagamento, lancamentos));
        lancamentos = List();
        formaPagamento = FormaPagamento(id: lancamento.idCategoria ,
            descricaoFormaPagamento: lancamento.descricaoFormaPagamento);
        totalFormaPagamento = 0;
      }
      if (lancamento.mesAno != mesAno) {
        if (mesAno != '') {
          listaResumoAnoMesCategoria.add(ResumoAnoMesFormaPagamento(formaPagamento.id,
              formaPagamento.descricaoFormaPagamento, totalFormaPagamento, lancamentos));
          listaResumo.add(ResumoMesAno(mesAno, listaResumoAnoMesCategoria ));
        }
        formaPagamento = FormaPagamento(id: lancamento.idFormaPagamento ,
            descricaoFormaPagamento: lancamento.descricaoFormaPagamento);
        listaResumoAnoMesCategoria = List();
        lancamentos = List();
        mesAno = lancamento.mesAno;
        totalFormaPagamento = 0;
      }
      totalFormaPagamento = totalFormaPagamento + lancamento.valor;
      lancamentos.add(lancamento);
    });
    listaResumoAnoMesCategoria.add(ResumoAnoMesFormaPagamento(formaPagamento.id,
        formaPagamento.descricaoFormaPagamento, totalFormaPagamento, lancamentos));
    listaResumo.add(ResumoMesAno(mesAno, listaResumoAnoMesCategoria));
    return listaResumo;
  }
  
  List<Widget> _listaItemsFormaPagamento(List<ResumoAnoMesFormaPagamento> listaResumoAnoMesFormaPagamento) {
    List<Widget> widgets = List();
    listaResumoAnoMesFormaPagamento.forEach((resumo) {
      widgets.add(ExpansionTile(
        title: FormaPagamentoResumo(
          formaPagamento: resumo.idFormaPagamento,
          descricao: resumo.descricaoFormaPagamento,
          valor: resumo.valor,
        ),
        children: _listaItemsLancamentos(resumo.lancamentos),
      ));
    });

    return widgets;

  }
  
  List<Widget> _listaItemsLancamentos(List<LancamentoFuturoResumo> listaLancamento) {
    List<Widget> widgets = List();
    listaLancamento.forEach((lancamento) {
      String descricao = lancamento.descricaoCategoria + ' - ' +
          lancamento.descricaoSubCategoria;
     widgets.add(Container(
        padding: EdgeInsets.fromLTRB(15, 0, 55, 5),
        child: FormaPagamentoResumo(formaPagamento: lancamento.idCategoria,
            descricao: descricao, valor: lancamento.valor),
      ));
    });

    return widgets;

  }

}

abstract class ListItem {}

// A ListItem that contains data to display a heading.
class MesAnoItem implements ListItem {
  final String mesAno;

  MesAnoItem(this.mesAno);
}

// A ListItem that contains data to display a message.
class LancamentoResumoItem implements ListItem {
  final LancamentoResumo lancamentoResumo;

  LancamentoResumoItem(this.lancamentoResumo);
}

class ResumoMesAno {
  final String mesAno;
  final List<ResumoAnoMesFormaPagamento> listaResumoAnoMesFormaPagamento;

  ResumoMesAno(this.mesAno, this.listaResumoAnoMesFormaPagamento);
}

class ResumoAnoMesFormaPagamento {
  final int idFormaPagamento;
  final String descricaoFormaPagamento;
  final int valor;
  final List<LancamentoFuturoResumo> lancamentos;

  ResumoAnoMesFormaPagamento(this.idFormaPagamento, this.descricaoFormaPagamento,
      this.valor, this.lancamentos);
}

class FormaPagamentoResumo extends StatelessWidget {
  final int formaPagamento;
  final String descricao;
  final int valor;

  FormaPagamentoResumo({
    Key key,
    this.formaPagamento,
    this.descricao,
    this.valor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              child: Text(descricao, textAlign: TextAlign.start,)
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: Text(Utils.intToCurrency(valor), textAlign: TextAlign.end),
            ),
          ),
        ],
      ),
    );

  }


}



