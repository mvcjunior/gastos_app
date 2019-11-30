import 'package:flutter/material.dart';
import 'package:gastos/utils/utils.dart';
import '../model/sub_categoria.dart';
import '../model/categoria.dart';


class SubCategoriaPagina extends StatefulWidget {
  final SubCategoria subCategoria;

  SubCategoriaPagina({Key key, @required this.subCategoria}) : super(key: key);
  @override
  _SubCategoriaPagina createState() {
    return _SubCategoriaPagina(subCategoria: this.subCategoria);
  }

}

class _SubCategoriaPagina extends State<SubCategoriaPagina> {

  final SubCategoria subCategoria;

  final subCategoriaController = TextEditingController();

  _SubCategoriaPagina({Key key, @required this.subCategoria}) : super();
  Future<List<Categoria>> _dropDownCategoria;

  final _formKey = GlobalKey<FormState>();
  Categoria _currentCategoria;
  Categoria categoriaAtual;

  int indiceCategoria = 0;


  @override
  void initState() {
    super.initState();
    _dropDownCategoria = CategoriaDatabase().categoriasFuture();
    subCategoriaController.text = this.subCategoria.descricaoSubCategoria != null
        ? this.subCategoria.descricaoSubCategoria
        : '';
    if (this.subCategoria.descricaoCategoria != null) {
      indiceCategoria = -1;
      categoriaAtual = Categoria(id: this.subCategoria.idCategoria,
          descricaoCategoria: this.subCategoria.descricaoCategoria);
    } else
      indiceCategoria =  0;
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
        title: Text('Sub Categorias'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder<List<Categoria>>(
                future: _dropDownCategoria,
                builder: (BuildContext context, AsyncSnapshot<List<Categoria>> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                    if (categoriaAtual == null) categoriaAtual = snapshot.data[0];
                    indiceCategoria = indiceCategoria != -1 
                        ? indiceCategoria 
                        : Utils().calculaIndice(categoriaAtual.id, snapshot.data);
                    _currentCategoria = snapshot.data[indiceCategoria];
                  return DropdownButtonFormField<Categoria>(
                    //key: _formDrop,
                    items: snapshot.data
                        .map((categoria) => DropdownMenuItem<Categoria>(
                      child: Text(categoria.descricaoCategoria),
                      value: categoria,
                    ))
                        .toList(),
                    onChanged: (categoria) {
                      setState(() {
                        categoriaAtual = categoria;
                        indiceCategoria = Utils().calculaIndice(categoria.id, snapshot.data);
                      });
                    },
                    value: _currentCategoria,
                    hint: Text('Select Categoria'),
                  );
                },
              ),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: subCategoriaController,
                validator: (descricaoSubCategoria) {
                  if (descricaoSubCategoria.isEmpty) {
                    return 'Preencha a SubCategoria';
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
                      // Process data.
                      if (this.subCategoria.id != null) {
                        SubCategoriaDatabase().updateSubCategoria(SubCategoria(id: this.subCategoria.id,
                            descricaoSubCategoria: subCategoriaController.text, idCategoria: categoriaAtual.id));
                      } else {
                        SubCategoriaDatabase().insertSubCategoria(SubCategoria(descricaoSubCategoria: subCategoriaController.text,
                            idCategoria: categoriaAtual.id));
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(this.subCategoria.id != null
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

}
