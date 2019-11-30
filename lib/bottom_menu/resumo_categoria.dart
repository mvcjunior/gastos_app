import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos/menu/page_lancamento.dart';
import 'package:gastos/model/categoria.dart';
import 'package:gastos/model/lancamento.dart';
import '../utils/utils.dart';

class ResumoCategoria extends StatefulWidget {
  ResumoCategoria({Key key}) : super(key: key);
  @override
  _ResumoCategoria createState() => _ResumoCategoria();
}


class _ResumoCategoria extends State<ResumoCategoria> {
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
                          children: _listaItemsCategoria(item.listaResumoAnoMesCategoria),
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
    List<LancamentoResumo> lancamentosResumo = await LancamentoDatabase().lancamentosResumo();
    List<ResumoMesAno> listaResumo = List();
    String mesAno = '';
    ResumoMesAno resumo;
    List<LancamentoResumo> lancamentos;
    List<ResumoAnoMesCategoria> listaResumoAnoMesCategoria;
    int totalCategoria = 0;
    Categoria categoria = Categoria(id: 0);
    lancamentosResumo.forEach((lancamento) {
      if (categoria.id != lancamento.idCategoria && lancamento.mesAno == mesAno) {
        listaResumoAnoMesCategoria.add(ResumoAnoMesCategoria(categoria.id,
            categoria.descricaoCategoria, totalCategoria, lancamentos));
        lancamentos = List();
        categoria = Categoria(id: lancamento.idCategoria ,
            descricaoCategoria: lancamento.descricaoCategoria);
        totalCategoria = 0;
      }
      if (lancamento.mesAno != mesAno) {
        if (mesAno != '') {
          listaResumoAnoMesCategoria.add(ResumoAnoMesCategoria(categoria.id,
              categoria.descricaoCategoria, totalCategoria, lancamentos));
          listaResumo.add(ResumoMesAno(mesAno, listaResumoAnoMesCategoria ));
        }
        categoria = Categoria(id: lancamento.idCategoria ,
            descricaoCategoria: lancamento.descricaoCategoria);
        listaResumoAnoMesCategoria = List();
        lancamentos = List();
        mesAno = lancamento.mesAno;
        totalCategoria = 0;
      }
      totalCategoria = totalCategoria + lancamento.valor;
      lancamentos.add(lancamento);
    });
    listaResumoAnoMesCategoria.add(ResumoAnoMesCategoria(categoria.id,
        categoria.descricaoCategoria, totalCategoria, lancamentos));
    listaResumo.add(ResumoMesAno(mesAno, listaResumoAnoMesCategoria));
    return listaResumo;
  }
  
  List<Widget> _listaItemsCategoria(List<ResumoAnoMesCategoria> listaResumoAnoMesCategoria) {
    List<Widget> widgets = List();
    listaResumoAnoMesCategoria.forEach((resumo) {
      widgets.add(ExpansionTile(
        title: CategoriaResumo(
          categoria: resumo.idCategoria,
          descricao: resumo.descricaoCategoria,
          valor: resumo.valor,
        ),
        children: _listaItemsSubCategoria(resumo.lancamentos),
      ));
    });

    return widgets;

  }
  
  List<Widget> _listaItemsSubCategoria(List<LancamentoResumo> listaLancamento) {
    List<Widget> widgets = List();
    listaLancamento.forEach((lancamento) {
      widgets.add(Container(
        padding: EdgeInsets.fromLTRB(15, 0, 55, 5),
        child: CategoriaResumo(categoria: lancamento.idSubCategoria,
            descricao: lancamento.descricaoSubCategoria, valor: lancamento.valor),
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
  final List<ResumoAnoMesCategoria> listaResumoAnoMesCategoria;

  ResumoMesAno(this.mesAno, this.listaResumoAnoMesCategoria);
}

class ResumoAnoMesCategoria {
  final int idCategoria;
  final String descricaoCategoria;
  final int valor;
  final List<LancamentoResumo> lancamentos;

  ResumoAnoMesCategoria(this.idCategoria, this.descricaoCategoria,
      this.valor, this.lancamentos);
}

class CategoriaResumo extends StatelessWidget {
  final int categoria;
  final String descricao;
  final int valor;

  CategoriaResumo({
    Key key,
    this.categoria,
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



