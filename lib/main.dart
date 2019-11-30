import 'package:flutter/material.dart';
import 'package:gastos/bottom_menu/page_grafico_mensal.dart';
import 'package:gastos/bottom_menu/resumo_credito.dart';
import 'package:gastos/menu/page_lancamento.dart';
import 'package:gastos/menu/page_restore.dart';
import 'package:gastos/model/lancamento.dart';
import 'package:gastos/bottom_menu/resumo_categoria.dart';
import 'bottom_menu/lista_gastos.dart';
import 'package:gastos/menu/page_lista_categoria.dart';
import 'package:gastos/menu/page_lista_sub_categoria.dart';
import 'package:gastos/menu/page_lista_formas_pagamento.dart';
import 'package:gastos/menu/page_backup.dart';
import 'package:quick_actions/quick_actions.dart';

import 'model/database.dart';

void main() async {
  final database = createDatabase();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gastos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          disabledColor: Colors.grey,
          textTheme: ButtonTextTheme.primary,
          minWidth: 2000,
        ),
      ),
      home: MyHomePage(title: 'Gastos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final begin = Offset(0.0, 1.0);
  static final end = Offset.zero;
  static final curve = Curves.ease;
  static final tween = Tween(begin: begin, end: end,  ).chain(CurveTween(curve: curve));

  @override
  void initState() {
    super.initState();
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      Navigator.push(context,
        MaterialPageRoute(builder: (context) => LancamentoPagina(lancamento: Lancamento(),)),
      );
    });
    quickActions.setShortcutItems(<ShortcutItem> [
      const ShortcutItem(
          type: 'novo_lancamento',
          localizedTitle: 'Lançamento',
          icon: 'ic_plus'
      )
    ]);

  }

  List<Widget> _widgetOptions = <Widget>[
    ListaGastos(),
    ResumoCategoria(),
    PaginaGraficoMensal(),
    ResumoCredito()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Route _createRouteListaCategorias() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ListaCategoriaPagina(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _createRouteSubCategorias() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ListaSubCategoriaPagina(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
         return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _createRouteFormaPagamento() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ListaFormaPagamentoPagina(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _createRouteBackup() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => BackupPagina(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  Route _createRouteRestore() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => RestorePagina(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () { Scaffold.of(context).openDrawer(); },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            }
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      drawer: Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
          child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Configuração'),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Formas Pagamento'),
                onTap: () {
                  Navigator.of(context).push(_createRouteFormaPagamento());
                },
              ),
              ListTile(
                title: Text('Categorias'),
                onTap: () {
                  Navigator.of(context).push(_createRouteListaCategorias());
                },
              ),
              ListTile(
                title: Text('Sub Categorias'),
                onTap: () {
                  Navigator.of(context).push(_createRouteSubCategorias());
                },
              ),
              ListTile(
                title: Text('Backup'),
                onTap: () {
                  Navigator.of(context).push(_createRouteBackup());
                },
              ),
              ListTile(
                title: Text('Restore'),
                onTap: () {
                  Navigator.of(context).push(_createRouteRestore());
                },
              ),
            ],
          ),
    ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('Lançamentos'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_to_home_screen),
            title: Text('Resumo'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            title: Text('Gráfico'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            title: Text('Crédito'),
          ),
        ],
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.blue,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LancamentoPagina(lancamento: Lancamento(),)),

          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}