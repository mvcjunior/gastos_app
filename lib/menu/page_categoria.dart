import 'package:flutter/material.dart';
import '../model/categoria.dart';

class CategoriaPagina extends StatefulWidget {
  final Categoria categoria;

  CategoriaPagina({Key key, @required this.categoria}) : super(key: key);
  @override
  _CategoriaPagina createState() {
    return _CategoriaPagina(categoria: this.categoria);
  }

}
class _CategoriaPagina extends State<CategoriaPagina> {

  final Categoria categoria;
  final categoriaController = TextEditingController();

  _CategoriaPagina({Key key, @required this.categoria}) : super();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    categoriaController.text = this.categoria.descricaoCategoria != null
        ? this.categoria.descricaoCategoria
        : '';
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
        title: Text('Categorias'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                controller: categoriaController,
                validator: (descricaoCategoria) {
                  if (descricaoCategoria.isEmpty || descricaoCategoria == '' ) {
                    return 'Preencha a Categoria';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState.validate()) {

                    CategoriaDatabase().existeDescricaoCategoria(Categoria(id: this.categoria.id, descricaoCategoria: categoriaController.text))
                        .then((existe) => {
                          if (!existe) {
                             if (this.categoria.id != null)
                                CategoriaDatabase().updateCategoria(Categoria(id: this.categoria.id,
                                    descricaoCategoria: categoriaController.text))
                             else
                                CategoriaDatabase().insertCategoria(Categoria(descricaoCategoria: categoriaController.text)),
                             Navigator.pop(context),
                           } else {
                             _categoriaRepetida('Categoria ja existente')
                           }
                      })
                        .catchError((onError) => {
                          _categoriaRepetida('Erro ao obter CATEGORIA')
                    });

                    }
                  },
                  child: Text(this.categoria.id != null
                      ? 'Salvar'
                      : 'Incluir'),
                ),
              ),
            ],
          ),
        ),
      ),

      );
  }

    Future<void> _categoriaRepetida(String valorAlerta) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(valorAlerta),
              ],
            ),
          ),
          actions: <Widget>[

            FlatButton(
              child: Text('Retorna'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

}
