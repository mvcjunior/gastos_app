import 'package:flutter/material.dart';
import 'page_categoria.dart';
import '../model/notificacao.dart';

class ListaNotificaoPagina extends StatelessWidget {

  Widget build(BuildContext context)  {

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
        title: Text('Notificações'),
      ),
      body: listaNotificacao(),
      );
  }

  Widget listaNotificacao() {
    return FutureBuilder(
        future: NotificacaoDatabase().lista(),
        builder: (context, notificacaoSnap) {
          return ListView.builder(
            itemCount: notificacaoSnap.data != null ? notificacaoSnap.data.length : 0,
            itemBuilder: (context, index) {

              final List<Notificacao> item = notificacaoSnap.data;
              return ListTile(
                title: Row(
                  children: <Widget>[
                    Text(item[index].package),
                    Text(item[index].message)
                  ],
                ),
                subtitle:  Text(item[index].timeStamp),
                onTap: () {
                },
              );
            },
          );

        }
    );


  }

}
