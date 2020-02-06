import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gastos/model/forma_pagamento.dart';
import 'package:gastos/model/lancamento.dart';
import 'package:gastos/model/sub_categoria.dart';
import 'package:gastos/utils/utils.dart';
import '../model/categoria.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';


class LancamentoPagina extends StatefulWidget {
  final Lancamento lancamento;

  LancamentoPagina({Key key, @required this.lancamento}) : super(key: key);
  @override
  _LancamentoPagina createState() {
    return _LancamentoPagina(lancamento: this.lancamento);
  }

}
class _LancamentoPagina extends State<LancamentoPagina> {

  final Lancamento lancamento;
  final String moeda = "R\$  ";

  var valorController = TextEditingController();
  var parceladoController = TextEditingController();

  _LancamentoPagina({Key key, @required this.lancamento}) : super();

  final _formKey = GlobalKey<FormState>();
  Categoria _currentCategoria;
  Categoria categoriaAtual;
  SubCategoria _currentSubCategoria;
  SubCategoria subCategoriaAtual;
  FormaPagamento _currentFormaPagamento;
  FormaPagamento formaPagamentoAtual;
  bool excluir;
  bool parcelado = false;
  FocusNode myFocusNode = FocusNode();


  Future<List<Categoria>> _dropDownCategoria;
  Future<List<SubCategoria>> _dropDownSubCategoria;
  Future<List<FormaPagamento>> _dropDownFormaPagamento;

  DateTime _dataInfo = DateTime.now();


  int indiceCategoria = 0;
  int indiceSubCategoria = 0;
  int indiceFormaPagamento = 0;

  @override
  void initState() {
    super.initState();
    valorController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
    _dropDownCategoria = CategoriaDatabase().categoriasFuture();
    _dropDownFormaPagamento = FormaPagamentoDatabase().formaPagamentoFuture();
    if (this.lancamento.id != null) {
      valorController.text = this.lancamento.valor.toString();
      parcelado = this.lancamento.parcelado == 'S' ? true : false;
      if (parcelado)
          parceladoController.text = this.lancamento.quantidadeParcelas.toString();
      valorController.text = this.lancamento.valor.toString();
      _dataInfo = DateTime.fromMillisecondsSinceEpoch(this.lancamento.data);
      categoriaAtual = Categoria(id: this.lancamento.idCategoria, descricaoCategoria: this.lancamento.descricaoCategoria);
      subCategoriaAtual = SubCategoria(id: this.lancamento.idSubCategoria, descricaoSubCategoria: this.lancamento.descricaoSubCategoria,
        idCategoria: this.lancamento.idCategoria);
      formaPagamentoAtual = FormaPagamento(id: this.lancamento.idFormaPagamento);
      subcategoria(this.lancamento.idCategoria);
      indiceFormaPagamento = -1;
      indiceCategoria = -1;
      indiceSubCategoria = -1;
    } else {
      _dropDownCategoria
          .then((categoria) {
              subcategoria(categoria[0].id);
      })
          .catchError((error) {
              subcategoria(1);
      });
    }
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  subcategoria(int idCategoria) {
    _dropDownSubCategoria = SubCategoriaDatabase().subCategoriasDeCategoriaFuture(idCategoria);
    _dropDownSubCategoria.whenComplete(() {
      setState(() {
      });
    });
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
        title: Text('Lancamento'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MaterialButton(
                padding: EdgeInsets.all(1),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.calendar_today, size: 28),
                    Text(' ${Utils.formataData(_dataInfo)}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  final dtPick = await showDatePicker(
                      context: context,
                      initialDate: _dataInfo,
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2100)
                  );
                  if (dtPick != null && dtPick != _dataInfo) {
                    setState(() {
                      _dataInfo = dtPick;
                    });
                  }
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: valorController,
                decoration: InputDecoration(
                    prefixText: moeda,
                    labelText: 'Valor'),
                validator: (valor) {
                  if (valor == '0,00')
                    return '';
                  return null;
                },
              ),
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
                        _dropDownSubCategoria = SubCategoriaDatabase().subCategoriasDeCategoriaFuture(categoria.id);
                        _dropDownSubCategoria
                            .then((res) => {
                              subCategoriaAtual = res[0] != null ? res[0] : null,
                              _currentSubCategoria = subCategoriaAtual
                            })
                            .catchError((error) => print(error));
                        indiceSubCategoria = -1;
                      });
                    },
                    value: _currentCategoria,
                  );
                },
              ),
              FutureBuilder<List<SubCategoria>>(
                future: _dropDownSubCategoria,
                builder: (BuildContext context, AsyncSnapshot<List<SubCategoria>> snapshot) {
                  if (!snapshot.hasData || snapshot.data.length == 0) return Center();
                  if (subCategoriaAtual == null) subCategoriaAtual = snapshot.data[0];

                  indiceSubCategoria = indiceSubCategoria != -1
                      ? indiceSubCategoria
                      : Utils().calculaIndice(subCategoriaAtual.id, snapshot.data);

                  _currentSubCategoria = snapshot.data[indiceSubCategoria];
                  return DropdownButtonFormField<SubCategoria>(
                    //key: _formDrop,
                    items: snapshot.data
                        .map((subCategoria) => DropdownMenuItem<SubCategoria>(
                      child: Text(subCategoria.descricaoSubCategoria),
                      value: subCategoria,
                    ))
                        .toList(),
                    onChanged: (subCategoria) {
                      setState(() {
                        subCategoriaAtual = subCategoria;
                        indiceSubCategoria = Utils().calculaIndice(subCategoria.id, snapshot.data);
                      });
                    },
                    value: _currentSubCategoria,
                    validator: (subcategoria) {
                      if (_currentSubCategoria.idCategoria != categoriaAtual.id) {
                        return '';
                      }
                      return null;
                    },
                  );
                },
              ),
              FutureBuilder<List<FormaPagamento>>(
                future: _dropDownFormaPagamento,
                builder: (BuildContext context, AsyncSnapshot<List<FormaPagamento>> snapshot) {
                  if (!snapshot.hasData || snapshot.data.length == 0) return Center();

                  if (formaPagamentoAtual == null) formaPagamentoAtual = snapshot.data[0];
                  indiceFormaPagamento = indiceFormaPagamento != -1
                      ? indiceFormaPagamento
                      : Utils().calculaIndice(formaPagamentoAtual.id, snapshot.data);
                  _currentFormaPagamento = snapshot.data[indiceFormaPagamento];
                  formaPagamentoAtual = snapshot.data[indiceFormaPagamento];
                  return DropdownButtonFormField<FormaPagamento>(
                    //key: _formDrop,
                    items: snapshot.data
                        .map((formaPagamento) => DropdownMenuItem<FormaPagamento>(
                      child: Text(formaPagamento.descricaoFormaPagamento),
                      value: formaPagamento,
                    ))
                        .toList(),
                    onChanged: (formaPagamento) {
                      setState(() {
                        formaPagamentoAtual = formaPagamento;
                        indiceFormaPagamento = Utils().calculaIndice(formaPagamento.id, snapshot.data);
                      });
                    },
                    value: _currentFormaPagamento,
                  );
                },
              ),
              Row(
                children: <Widget>[
                  Text('Parcelado'),
                  Switch(
                    value: parcelado,
                    onChanged: (valor) {
                      if (parcelado) {
                        parceladoController.text = '';
                        parcelado = false;
                      }
                      else {
                        parcelado = true;
                        FocusScope.of(context).requestFocus(myFocusNode);
                      }
                      setState(() {

                      });
                    },
                  ),
                  SizedBox(
                    width: 30,
                    child:  TextFormField(
                      focusNode: myFocusNode,
                      textAlign: TextAlign.center,
                      enabled: parcelado,
                      keyboardType: TextInputType.number,
                      controller: parceladoController,
                      validator: (valor) {
                        if (!parcelado)
                          return null;
                        if (valor == '0' || valor == '')
                          return '';
                        return null;
                      },
                    ),
                  ),


                ],
              ),
              Center(
                child: MaterialButton(
                  minWidth: 2000,
                  color: Colors.blue,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      int valor = int.parse(valorController.text.replaceAll(',', '').replaceAll('.', ''));
                      int data = _dataInfo.millisecondsSinceEpoch;
                      String mensagem;
                      if (this.lancamento.id == null) {
                        LancamentoDatabase().insert(Lancamento(idSubCategoria: subCategoriaAtual.id,
                            idFormaPagamento: formaPagamentoAtual.id, valor: valor, data: data, parcelado: parcelado ? 'S' : 'N',
                            quantidadeParcelas: parcelado ? int.parse(parceladoController.text) : 0), formaPagamentoAtual);
                        mensagem = 'Lancamento incluido com sucesso';
                      } else {
                        LancamentoDatabase().updateLancamento(Lancamento(id: this.lancamento.id, idSubCategoria: subCategoriaAtual.id,
                            idFormaPagamento: formaPagamentoAtual.id, valor: valor, data: data, parcelado: parcelado ? 'S' : 'N',
                            quantidadeParcelas: parcelado ? int.parse(parceladoController.text) : 0), formaPagamentoAtual);
                        mensagem = 'Lancamento atualizado com sucesso';
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text(this.lancamento.id != null
                      ? 'Salvar'
                      : 'Incluir'),
                ),

              ),
              this.lancamento.id != null ? Center(
                 child: RaisedButton(
                     onPressed: () {
                        _confirma().then((r) => {
                            if (excluir) {
                              LancamentoDatabase().deleteLancamento(this.lancamento.id),
                              Navigator.pop(context)
                            }
                         });
                     },
                     child: Text('Excluir'),
                   ),
               ) : Center()

            ],
          ),
        ),
      ),

      );
  }

  Future<void> _confirma() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Confirma exclusao do lancamento?'),
                ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancela'),
              onPressed: () {
                excluir = false;
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Confirma'),
              onPressed: () {
                excluir = true;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
