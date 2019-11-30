import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/utils.dart';
import '../utils/restore.dart';


class RestorePagina extends StatefulWidget {

  RestorePagina({Key key}) : super(key: key);

  @override
  _BackupRestore createState() => _BackupRestore();
}


class _BackupRestore extends State<RestorePagina> {
  List<ListItem> items;
  Directory diretorio = Directory('/');


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
          title: Text('Restore'),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
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
            } else if (item is FileItem) {
                return ListTile(
                  title: Text(item.fileSystemEntity.path, style: TextStyle(color: Colors.grey),),
                  onTap: () {
                      Restore.executa(item.fileSystemEntity.path)
                        .then((res){
                          _finalizado().whenComplete(volta);
                      })
                        .catchError((error) {
                          _finalizadoErro().whenComplete(volta);
                      });
                  } ,
                );

              }
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

  volta() {
    Navigator.pop(context);
  }

  List<ListItem> geraItems() {
    List<ListItem> items = List<ListItem>();
    final FirstItem first = new FirstItem(diretorio.path);
    items.add(first);
    List<FileSystemEntity> diretorios = geraDiretorio();
    diretorios.forEach((f) => {
      if (f.statSync().type == FileSystemEntityType.file) {
        if (f.path.contains('.bkp') && f.path.contains('gastos_'))
          items.add(FileItem(f))
      }
      else
        items.add(DirectoryItem(f))
    });
    return items;
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
                Text('Restore finalizado'),
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

  Future<void> _finalizadoErro() async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Nao foi possivel finalizar o restore.'),
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

  Future<void> _erroDiretorio(int codigo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
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

class FileItem implements ListItem {
  final FileSystemEntity fileSystemEntity;

  FileItem(this.fileSystemEntity);
}

