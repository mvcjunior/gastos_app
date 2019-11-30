import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/forma_pagamento.dart';

enum Tipo { credito, debito }

class FormaPagamentoPagina extends StatefulWidget {
  final FormaPagamento formaPagamento;

  FormaPagamentoPagina({Key key, @required this.formaPagamento}) : super(key: key);

  @override
  _FormaPagamentoPagina createState() => _FormaPagamentoPagina(formaPagamento: this.formaPagamento);
}


class _FormaPagamentoPagina extends State<FormaPagamentoPagina> {

  final FormaPagamento formaPagamento;

  _FormaPagamentoPagina({Key key, @required this.formaPagamento});

  final _formKey = GlobalKey<FormState>();
  Tipo _character;
  bool _dadosCredito;


  @override
  void initState() {
    super.initState();
    formaPagamentoController.text = this.formaPagamento.descricaoFormaPagamento != null
        ? this.formaPagamento.descricaoFormaPagamento
        : '';
    diaVencimentoController.text = this.formaPagamento.diaPagamento != 0 && this.formaPagamento.diaPagamento != null
        ? this.formaPagamento.diaPagamento.toString() : '';
    melhorDataController.text = this.formaPagamento.melhorData != 0 && this.formaPagamento.melhorData != null
      ? this.formaPagamento.melhorData.toString() : '';
    if (this.formaPagamento.tipo != null)
      if (this.formaPagamento.tipo.contains('credito')) {
        _character = Tipo.credito;
        _dadosCredito = true;
      } else {
        _character = Tipo.debito;
        _dadosCredito = false;
      }
    else
      _character = Tipo.credito;
  }
  final formaPagamentoController = TextEditingController();
  final diaVencimentoController = TextEditingController();
  final melhorDataController = TextEditingController();


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
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: formaPagamentoController,
                decoration: InputDecoration(
                  labelText: 'Descricao',
                ),
                //initialValue: '',
                validator: (formaPagamento) {
                  if (formaPagamento.isEmpty) {
                    return 'Preencha a Forma Pagamento';
                  }
                  return null;
                },
              ),
              Column(
                children: <Widget>[
                  ListTile(
                    title: const Text('Debito'),
                    leading: Radio(
                      value: Tipo.debito,
                      groupValue: _character,
                      onChanged: (Tipo value) {
                        setState(() {
                          _character = value;
                          _dadosCredito = false;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Credito'),
                    leading: Radio(
                      value: Tipo.credito,
                      groupValue: _character,
                      onChanged: (Tipo value) {
                        setState(() {
                          _character = value;
                          _dadosCredito = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: diaVencimentoController,
                enabled: _dadosCredito,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Dia Vencimento',
                )
                ,
                validator: (diaVencimento) {
                  if (diaVencimento.isEmpty && _dadosCredito) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: melhorDataController,
                keyboardType: TextInputType.number,
                enabled: _dadosCredito,
                decoration: InputDecoration(
                  labelText: 'Melhor Data',
                ),
                validator: (melhorData) {
                  if (melhorData.isEmpty && _dadosCredito) {
                    return 'Please enter some text';
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
                      FormaPagamentoDatabase().existeDescricaoFormaPagamento(FormaPagamento(id: this.formaPagamento.id,
                          descricaoFormaPagamento: formaPagamentoController.text))
                        .then((existe) => {
                          if (!existe) {
                            if (this.formaPagamento.id != null)
                              FormaPagamentoDatabase().updateFormaPagamento(FormaPagamento(id: this.formaPagamento.id,
                                descricaoFormaPagamento: formaPagamentoController.text, tipo: _character.toString(),
                                diaPagamento: int.parse(diaVencimentoController.text), 
                                  melhorData: int.parse(melhorDataController.text)  ))
                             else
                              FormaPagamentoDatabase().insertFormaPagamento(FormaPagamento(descricaoFormaPagamento: formaPagamentoController.text,
                                tipo: _character.toString(), diaPagamento: int.parse(diaVencimentoController.text), 
                                  melhorData: int.parse(melhorDataController.text))),

                            Navigator.pop(context),// Process data.
                          } else {
                            _formaPagamentoRepetida('Forma Pagamento ja existente'),
                          }
                      })
                        .catchError((error) => {
                          print(error),
                          _formaPagamentoRepetida('Erro ao obter FORMA PAGAMENTO'),
                      });
                    }
                  },
                  child: Text(this.formaPagamento.id != 0 ? 'Salvar' : 'Incluir'),
                ),
              ),
            ],
          ),
        ),
      ),
      );


}

  Future<void> _formaPagamentoRepetida(String valorAlerta) async {
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


