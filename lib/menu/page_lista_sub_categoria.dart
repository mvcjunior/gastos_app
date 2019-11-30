import 'package:flutter/material.dart';
import '../model/sub_categoria.dart';


import 'page_sub_categoria.dart';

class ListaSubCategoriaPagina extends StatefulWidget {
  ListaSubCategoriaPagina({Key key}) : super(key: key);

  @override
  _ListaSubCategoriaPagina createState() => _ListaSubCategoriaPagina();
}


class _ListaSubCategoriaPagina extends State<ListaSubCategoriaPagina> {

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
        title: Text('Sub Categorias'),
      ),
      body: listaSubCategoria(),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubCategoriaPagina(subCategoria: SubCategoria())),
            );
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        )
      );
  }

  Widget listaSubCategoria() {
    return FutureBuilder(
        future: SubCategoriaDatabase().subCategoriasFuture(),
        builder: (context, subCategoriaSnap) {
          return ListView.builder(
            itemCount: subCategoriaSnap.data!= null ? subCategoriaSnap.data.length : 0,
            itemBuilder: (context, index) {
              final List<SubCategoria> item = subCategoriaSnap.data;
              return ListTile(
                title: Text(item[index].descricaoSubCategoria),
                subtitle: Text(item[index].descricaoCategoria),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SubCategoriaPagina(subCategoria: item[index])),
                  );
                },
              );
            },
          );

        }
    );


  }


}
