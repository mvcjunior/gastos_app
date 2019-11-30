import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos/bottom_menu/resumo_categoria.dart';
import 'package:gastos/model/lancamento.dart';
import 'package:gastos/utils/utils.dart';
import 'package:gastos/bottom_menu/grafico_mensal.dart';

class PaginaGraficoMensal extends StatefulWidget {
  PaginaGraficoMensal({Key key}) : super(key: key);
  @override
  _PaginaGraficoMensal createState() => _PaginaGraficoMensal();
}


class _PaginaGraficoMensal extends State<PaginaGraficoMensal> {

  Future<List<ResumoMesAno>> _dropDownMesAno;
  Future<Widget> _grafico;
  ResumoMesAno _resumoMesAno;

  @override
  void initState() {
    super.initState();
    _dropDownMesAno = LancamentoDatabase().resumoAnoMes();
    _dropDownMesAno.then((resumo) {
      _resumoMesAno = resumo[0];
      _grafico = graficoMesAno(_resumoMesAno);
      _grafico.then((w){
        setState(() {

        });
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text('Periodo', textAlign: TextAlign.center,),
              ),
            ),
            Expanded(
              flex: 4,
              child: FutureBuilder(
                future: _dropDownMesAno,
                builder: (BuildContext context, AsyncSnapshot<List<ResumoMesAno>> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  return DropdownButtonFormField<ResumoMesAno>(
                    //key: _formDrop,
                    items: snapshot.data
                        .map((resumo) => DropdownMenuItem<ResumoMesAno>(
                      child: Text(Utils.formataMesAno(resumo.mesAno)),
                      value: resumo,
                    ))
                        .toList(),
                    onChanged: (resumo) {
                      setState(() {
                        _resumoMesAno = resumo;
                        _grafico = graficoMesAno(_resumoMesAno);
                      });
                    },
                    value: _resumoMesAno,
                  );
                },
              ),
            )
          ],
        ),
        FutureBuilder(
          future: _grafico,
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return snapshot.data;
          }
        ),
      ],
    );
  }

  Future<Widget> graficoMesAno (ResumoMesAno resumo) async {
    final List<GastosCategoria> seriesList = await LancamentoDatabase().resumoCategoriaAnoMes(resumo);
    return GraficoMensal(
      seriesList: seriesList,
      animate: true,
    );
  }
}