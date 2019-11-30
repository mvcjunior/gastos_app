import 'package:flutter/material.dart';
import 'page_categoria.dart';
import '../model/categoria.dart';
import 'dart:async';

class ListaCategoriaPagina extends StatelessWidget {

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
        title: Text('Categorias'),
      ),
      body: listaCategoria(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoriaPagina(categoria: Categoria(),)),
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      )
      );
  }

  Widget listaCategoria() {
    return FutureBuilder(
        future: CategoriaDatabase().categoriasFuture(),
        builder: (context, categoriaSnap) {
          return ListView.builder(
            itemCount: categoriaSnap.data != null ? categoriaSnap.data.length : 0,
            itemBuilder: (context, index) {

              final List<Categoria> item = categoriaSnap.data;
              return ListTile(
                title: Text(item[index].descricaoCategoria),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriaPagina(categoria: item[index])),
                  );
                },
              );
            },
          );

        }
    );


  }

}
