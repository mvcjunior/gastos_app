import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos/menu/page_lancamento.dart';
import 'package:gastos/model/lancamento.dart';
import '../utils/utils.dart';

class ListaGastos extends StatefulWidget {
  ListaGastos({Key key}) : super(key: key);
  @override
  _ListaGastos createState() => _ListaGastos();
}


class _ListaGastos extends State<ListaGastos> {

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: LancamentoDatabase().lancamentosFuture(),
        builder: (context, lancamentosSnap) {
      return ListView.builder(
        itemCount: lancamentosSnap.data != null ? lancamentosSnap.data.length : 0,
        itemBuilder: (context, index) {
          final List<Lancamento> item = lancamentosSnap.data;
          return ListTile(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                      Text(
                          Utils.intToData(item[index].data),
                          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5)
                      ),
                      Text(
                          Utils.intToCurrency(item[index].valor),
                          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3)
                      ),
                    ],
              ),
            ),
            subtitle: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(item[index].descricaoCategoria, style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0)),
                    Text(item[index].descricaoSubCategoria, style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(Utils.formataParcelado(item[index].quantidadeParcelas), style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.8)),
                    Text(item[index].descricaoFormaPagamento, style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.8))
                  ],
                ),
                Divider()
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LancamentoPagina(lancamento: item[index])));
              }
              );
            },
          );
        },
      );
  }
}