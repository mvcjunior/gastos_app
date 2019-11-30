import 'package:flutter/material.dart';
import 'page_forma_pagamento.dart';
import '../model/forma_pagamento.dart';

class ListaFormaPagamentoPagina extends StatefulWidget {

  ListaFormaPagamentoPagina({Key key}) : super(key: key);

  @override
  _ListaFormaPagamentoPagina createState() => _ListaFormaPagamentoPagina();

}

class _ListaFormaPagamentoPagina extends State<ListaFormaPagamentoPagina> {


  @override
  void initState() {
    super.initState();

  }

  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                  },
              );
            }
        ),
        title: Text('Forma Pagamento'),
      ),
      body: listaFormaPagamento(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormaPagamentoPagina(formaPagamento: FormaPagamento(),)),
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      )
      );
  }

  Widget listaFormaPagamento() {
    return FutureBuilder(
        future: FormaPagamentoDatabase().formaPagamentoFuture(),
        builder: (context, formaPagamentoSnap) {
          return ListView.builder(
            itemCount: formaPagamentoSnap.data != null ? formaPagamentoSnap.data.length : 0,
            itemBuilder: (context, index) {
              final List<FormaPagamento> item = formaPagamentoSnap.data;
              return ListTile(
                title: Text(item[index].descricaoFormaPagamento),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FormaPagamentoPagina(formaPagamento: item[index])),
                  );
                },
              );
            },
          );

        }
    );
  }
}
