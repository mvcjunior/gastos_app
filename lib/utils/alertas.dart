
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as prefix0;

class Alertas {
  static Future<void> finalizado(context) async {
    return showDialog<void>(

      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mensagem'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Backup finalizado'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Voltar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}