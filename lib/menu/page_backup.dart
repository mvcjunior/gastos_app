import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/utils.dart';
import '../utils/backup.dart';
import '../utils/alertas.dart';


class BackupPagina extends StatefulWidget {

  BackupPagina({Key key}) : super(key: key);

  @override
  _BackupPagina createState() => _BackupPagina();
}


class _BackupPagina extends State<BackupPagina> {
  List<ListItem> items;
  //List<FileSystemEntity> listaDiretorios;
  Directory diretorio = Directory('/');
  //Directory diretorio = Directory.current;


  @override
  void initState() {
    super.initState();
    items = geraItems();

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
          title: Text('Backup'),
        ),
        body: listaDiretorio()
    );
  }

  Widget listaDiretorio() {
    return ListView.builder(
            itemCount: items != null ? items.length : 0,
            itemBuilder: (context, index) {
              final ListItem item = items[index];
              if (item is FirstItem) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: MaterialButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child:Text(
                            item.diretorio,
                            style: TextStyle(fontSize: 23),
                          ),
                          onPressed: () {
                            diretorio = Directory(Utils.voltaDiretorio(diretorio.path));
                            items = geraItems();
                            setState(() {

                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          color: Colors.blue,
                          child: Text('Inicia', style: TextStyle(fontSize: 10),),
                          onPressed: (){
                            Backup.executa(diretorio.path)
                                .then((void a) {
                              _finalizado();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      )
                    ],
                  )
                );
              } else if (item is DirectoryItem) {
                return ListTile(
                  title: Text(item.fileSystemEntity.path),
                  onTap: () {
                    try {
                      diretorio = Directory(item.fileSystemEntity.path);
                    } catch(e) {
                      print(e);
                    }

                    items = geraItems();
                    setState(() {

                    });
                  } ,
                );
            };
            }
          );
  }

  List<FileSystemEntity> geraDiretorio() {
    try {
      return diretorio.listSync(recursive: false, followLinks: false);
    } catch (e) {
      FileSystemException error = e;
      _erroDiretorio(error.osError.errorCode);
    }
  }

  List<ListItem> geraItems() {
    List<ListItem> items = List<ListItem>();
    final FirstItem first = new FirstItem(diretorio.path);
    items.add(first);
    List<FileSystemEntity> diretorios = geraDiretorio();
    diretorios.forEach((f) => {
      if (f.statSync().type == FileSystemEntityType.directory)
        items.add(DirectoryItem(f))
    });
    return items;
  }


  Future<void> _erroDiretorio(int codigo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(codigo==13 ?
                  'Acesso nao permitido.' :
                  'Arquivo nao e um diretorio.'),
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

  Future<void> _finalizado() async {
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

abstract class ListItem {}

// A ListItem that contains data to display a heading.
class FirstItem implements ListItem {
  final String diretorio;

  FirstItem(this.diretorio);
}

// A ListItem that contains data to display a message.
class DirectoryItem implements ListItem {
  final FileSystemEntity fileSystemEntity;

  DirectoryItem(this.fileSystemEntity);
}
